//
//  CurationChatViewModel.swift
//  HaruUp
//
//  Created on 2026/03/30.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

// MARK: - Chat Message Model

enum ChatMessageType {
    case bot
    case user
}

struct ChatMessage {
    let id: UUID
    let type: ChatMessageType
    let text: String
    let highlightedText: String?
    let suggestions: [String]
    let subtitleText: String?
    let isShimmering: Bool

    init(
        type: ChatMessageType,
        text: String,
        highlightedText: String? = nil,
        suggestions: [String] = [],
        subtitleText: String? = nil,
        isShimmering: Bool = false
    ) {
        self.id = UUID()
        self.type = type
        self.text = text
        self.highlightedText = highlightedText
        self.suggestions = suggestions
        self.subtitleText = subtitleText
        self.isShimmering = isShimmering
    }
}

// MARK: - Display Item

enum ChatDisplayItem {
    case botMessage(ChatMessage)
    case userMessage(ChatMessage)
    case suggestionChips([String])
}


// MARK: - ViewModel

final class CurationChatViewModel {

    struct Input {
        let viewDidAppear: Observable<Void>
        let sendButtonTapped: Observable<String>
        let suggestionTapped: Observable<String>
    }

    struct Output {
        let displayItems: Driver<[ChatDisplayItem]>
        let isCompleted: Driver<Bool>
        let isLoading: Driver<Bool>
        let characterName: Driver<String>
        let characterImageName: Driver<String>
        let prefillText: Driver<String>
    }

    private weak var coordinator: CurationChatCoordinator?
    private let disposeBag = DisposeBag()

    private let characterId: Int
    private let messagesRelay = BehaviorRelay<[ChatMessage]>(value: [])
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)
    private let prefillTextRelay = PublishRelay<String>()
    
    private let chatbotService: ChatbotService
    private var sessionId: String?
    private var completedMissions: [ChatbotMissionDto] = []
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - Chat Phase
    private enum ChatPhase { case nickname, chatbot }
    private var currentPhase: ChatPhase = .nickname
    private var collectedNickname: String = ""
    private var isLastQuestion: Bool = false

    init(coordinator: CurationChatCoordinator, characterId: Int, chatbotService: ChatbotService) {
        self.coordinator = coordinator
        self.characterId = characterId
        self.chatbotService = chatbotService
    }

    func transform(input: Input) -> Output {
        let characterName: String
        let characterImageName: String

        switch characterId {
        case 1:
            characterName = "하루"
            characterImageName = "character_haru_profile"
        case 2:
            characterName = "나루"
            characterImageName = "character_naru_profile"
        default:
            characterName = "하루"
            characterImageName = "character_haru_profile"
        }

        // 화면 표시 시 닉네임 질문 먼저 표시
        input.viewDidAppear
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.showNicknameQuestion()
            })
            .disposed(by: disposeBag)

        // 사용자 답변 전송
        input.sendButtonTapped
            .subscribe(onNext: { [weak self] answer in
                self?.handleUserAnswer(answer)
            })
            .disposed(by: disposeBag)

        // 추천 칩 탭 → 입력창에 텍스트 채우기
        input.suggestionTapped
            .subscribe(onNext: { [weak self] text in
                self?.prefillTextRelay.accept(text)
            })
            .disposed(by: disposeBag)

        // 완료 시 다음 화면으로 이동
        isCompletedRelay
            .filter { $0 }
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.didFinishChat(missions: self.completedMissions, nickname: self.collectedNickname)
            })
            .disposed(by: disposeBag)

        // messages → displayItems 매핑
        let displayItems = messagesRelay
            .map { messages -> [ChatDisplayItem] in
                var items: [ChatDisplayItem] = []
                for message in messages {
                    switch message.type {
                    case .bot:
                        items.append(.botMessage(message))
                        if !message.suggestions.isEmpty {
                            items.append(.suggestionChips(message.suggestions))
                        }
                    case .user:
                        items.append(.userMessage(message))
                    }
                }
                return items
            }
            .asDriver(onErrorJustReturn: [])

        return Output(
            displayItems: displayItems,
            isCompleted: isCompletedRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            characterName: Driver.just(characterName),
            characterImageName: Driver.just(characterImageName),
            prefillText: prefillTextRelay.asDriver(onErrorJustReturn: "")
        )
    }
    
    // 처음부터 다시 시작하기 로직
    func restartChat() {
        messagesRelay.accept([])
        sessionId = nil
        completedMissions = []
        isCompletedRelay.accept(false)
        currentPhase = .nickname
        collectedNickname = ""
        isLastQuestion = false
        showNicknameQuestion()
    }

    // MARK: - Private
    private func handleUserAnswer(_ answer: String) {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch currentPhase {
        case .nickname:
            handleNicknameInput(trimmed)
        case .chatbot:
            guard let sessionId = sessionId else { return }
            appendMessage(ChatMessage(type: .user, text: trimmed))

            // 마지막 질문의 답변인 경우 미션 생성 중 메시지를 먼저 표시
            if isLastQuestion {
                appendMessage(ChatMessage(
                    type: .bot,
                    text: "\(collectedNickname)님을 위한 맞춤 미션을 만드는 중이에요!",
                    isShimmering: true
                ))
            }

            isLoadingRelay.accept(true)
            chatbotService.answer(sessionId: sessionId, answer: trimmed)
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onSuccess: { [weak self] response in
                        self?.isLoadingRelay.accept(false)
                        self?.handleAnswerResponse(response.data)
                    },
                    onFailure: { [weak self] _ in
                        self?.isLoadingRelay.accept(false)
                        self?.appendMessage(ChatMessage(type: .bot, text: "오류가 발생했어요. 다시 시도해주세요."))
                    }
                )
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Nickname Phase

    private func showNicknameQuestion() {
        appendMessage(ChatMessage(
            type: .bot,
            text: "닉네임을 입력해주세요.\n하루업에서 불리고 싶은 이름을 적어주세요."
        ))
    }

    private func handleNicknameInput(_ nickname: String) {
        appendMessage(ChatMessage(type: .user, text: nickname))

        if let errorMessage = validateNicknameLocally(nickname) {
            appendMessage(ChatMessage(type: .bot, text: errorMessage))
            return
        }

        isLoadingRelay.accept(true)
        checkNicknameDuplicate(nickname)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] result in
                    guard let self = self else { return }
                    self.isLoadingRelay.accept(false)
                    switch result {
                    case .success:
                        self.collectedNickname = nickname
                        self.appendMessage(ChatMessage(
                            type: .bot,
                            text: "\(nickname)님, 반갑습니다! 🎉\n이제 목표를 설정해볼게요."
                        ))
                        self.currentPhase = .chatbot
                        self.startChatbot()
                    case .duplicated:
                        self.appendMessage(ChatMessage(
                            type: .bot,
                            text: "이미 사용 중인 닉네임이에요.\n다른 닉네임을 입력해주세요."
                        ))
                    default:
                        break
                    }
                },
                onError: { [weak self] _ in
                    self?.isLoadingRelay.accept(false)
                    self?.appendMessage(ChatMessage(
                        type: .bot,
                        text: "닉네임 확인 중 오류가 발생했어요.\n다시 시도해주세요."
                    ))
                }
            )
            .disposed(by: disposeBag)
    }

    /// 로컬 유효성 검사 — 오류 메시지 반환, 통과 시 nil
    private func validateNicknameLocally(_ nickname: String) -> String? {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        if trimmed.count < 2 { return "닉네임은 최소 2글자 이상이어야 해요." }
        if trimmed.count > 10 { return "닉네임은 최대 10글자까지 가능해요." }
        if !isOnlyKorean(trimmed) { return "한글만 입력이 가능해요.\n다시 입력해주세요." }
        if !isCompleteKorean(trimmed) { return "자음이나 모음만으로는 닉네임을 만들 수 없어요.\n완성된 한글로 입력해주세요." }
        return nil
    }

    private func isOnlyKorean(_ text: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[가-힣ㄱ-ㅎㅏ-ㅣ\\s]*$")
        return predicate.evaluate(with: text)
    }

    private func isCompleteKorean(_ text: String) -> Bool {
        for char in text.replacingOccurrences(of: " ", with: "") {
            let v = char.unicodeScalars.first!.value
            let isComplete  = (0xAC00...0xD7A3).contains(v)
            let isChosung   = (0x1100...0x1112).contains(v)
            let isJungsung  = (0x1161...0x1175).contains(v)
            let isJongsung  = (0x11A8...0x11C2).contains(v)
            let isJamoCompat = (0x3131...0x318E).contains(v)
            if !isComplete && (isChosung || isJungsung || isJongsung || isJamoCompat) { return false }
            if !isComplete && !isChosung && !isJungsung && !isJongsung && !isJamoCompat { return false }
        }
        return true
    }

    private func checkNicknameDuplicate(_ nickname: String) -> Observable<NicknameValidationResult> {
        return Observable.create { observer in
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                observer.onError(NSError(domain: "AuthError", code: 401))
                return Disposables.create()
            }
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "jwt-token": refreshToken
            ]
            let request = AF.request(
                NetworkDefine.ProfileAPI.nicknameDuplicateCheck.url,
                method: .post,
                parameters: UpdateNicknameRequest(nickName: nickname),
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let success = json["success"] as? Bool {
                        observer.onNext(success ? .success : .duplicated)
                    } else {
                        observer.onError(NSError(domain: "ParsingError", code: -1))
                        return
                    }
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { request.cancel() }
        }
    }
    
    private func startChatbot() {
        isLoadingRelay.accept(true)

        chatbotService.start()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let self = self, let data = response.data else { return }
                    self.isLoadingRelay.accept(false)
                    self.sessionId = data.sessionId

                    // 첫 질문 + 예시 칩 표시
                    self.appendMessage(ChatMessage(
                        type: .bot,
                        text: data.question,
                        suggestions: data.examples
                    ))
                },
                onFailure: { [weak self] _ in
                    self?.isLoadingRelay.accept(false)
                    self?.appendMessage(ChatMessage(type: .bot, text: "연결에 실패했어요. 다시 시도해주세요."))
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func handleAnswerResponse(_ data: ChatbotAnswerResultData?) {
        guard let data = data else { return }
        
        if data.isCompleted == true {
            // 완료 → 미션 저장 후 화면 전환
            completedMissions = data.missions ?? []
            appendMessage(ChatMessage(type: .bot, text: "좋아요! 답변을 바탕으로 맞춤 미션을 준비했어요!!!🎉"))
            isCompletedRelay.accept(true)
        }
        else {
            // 진행 중 → 다음 질문 표시
            guard let question = data.question else { return }
            let isLast = data.isLast ?? false
            isLastQuestion = isLast   // 다음 답변이 마지막인지 기록

            appendMessage(ChatMessage(type: .bot, text: question,
                                      subtitleText: isLast ? "마지막 질문이에요!" : nil))
        }
    }
    
    
    private func appendMessage(_ message: ChatMessage) {
        var msgs = messagesRelay.value
        msgs.append(message)
        messagesRelay.accept(msgs)
    }
}
