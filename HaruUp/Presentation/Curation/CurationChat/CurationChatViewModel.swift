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
    /// 사용자가 고쳐서 다시 입력해야 하는 안내인지 (목표를 하나만 입력해달라는 경우 등)
    let isError: Bool

    init(
        type: ChatMessageType,
        text: String,
        highlightedText: String? = nil,
        suggestions: [String] = [],
        subtitleText: String? = nil,
        isShimmering: Bool = false,
        isError: Bool = false
    ) {
        self.id = UUID()
        self.type = type
        self.text = text
        self.highlightedText = highlightedText
        self.suggestions = suggestions
        self.subtitleText = subtitleText
        self.isShimmering = isShimmering
        self.isError = isError
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
        /// 0.0 ~ 1.0. 질문 개수가 대화마다 달라져 단계 수로는 표현할 수 없다.
        let progress: Driver<Float>
        /// 입력창에 표시할 안내 문구 (서버가 첫 질문에 내려준다)
        let inputPlaceholder: Driver<String>
    }

    /// 진행률 계산에 쓰는 기준 단계 수 (닉네임 1 + 목표 1 + 꼬리질문 5).
    /// 서버가 꼬리질문을 3~8개 사이에서 조절하므로 실제 총 개수는 대화가 끝나야 알 수 있다.
    /// 그래서 이 값은 어디까지나 기준이고, 대화가 길어지면 분모를 늘려 진행률이 역행하지 않게 한다.
    private static let baselineTotalSteps = 7

    /// 완료 전에는 진행률을 이 값 이상으로 올리지 않는다. 다 찼는데 질문이 더 나오는 상황을 막는다.
    private static let maxProgressBeforeComplete: Float = 0.95

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
    private let progressRelay = BehaviorRelay<Float>(value: 1.0 / Float(baselineTotalSteps))
    private let inputPlaceholderRelay = BehaviorRelay<String>(value: "답변을 입력해주세요")

    // MARK: - Chat Phase
    private enum ChatPhase { case nickname, chatbot }
    private var currentPhase: ChatPhase = .nickname
    private var collectedNickname: String = ""
    private var isLastQuestion: Bool = false

    /// 마무리 확인("이대로 마무리할까요?")을 띄워 두고 사용자의 예/아니오를 기다리는 중인지.
    /// 이 상태에서 보낸 답변은 꼬리질문 답변이 아니라 마무리 여부 선택이다.
    private var awaitingFinishConfirmation: Bool = false

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
            prefillText: prefillTextRelay.asDriver(onErrorJustReturn: ""),
            progress: progressRelay.asDriver(),
            inputPlaceholder: inputPlaceholderRelay.asDriver()
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
        awaitingFinishConfirmation = false
        progressRelay.accept(1.0 / Float(Self.baselineTotalSteps))
        inputPlaceholderRelay.accept("답변을 입력해주세요")
        showNicknameQuestion()
    }

    /// 마무리 확인 답변이 긍정인지 판단한다.
    ///
    /// 판정 자체는 서버가 하고, 앱은 "미션 생성 중" 표시를 미리 띄울지 정하는 데만 쓴다.
    /// 그래서 틀려도 화면 연출만 달라지고 대화 흐름에는 영향이 없다.
    /// 부정을 먼저 걸러야 "아니요, 미션 만들어주세요" 같은 답을 긍정으로 잘못 읽지 않는다.
    private func isAffirmative(_ answer: String) -> Bool {
        let negatives = ["아니", "아뇨", "싫", "더 ", "계속", "나중"]
        if negatives.contains(where: { answer.contains($0) }) { return false }

        let affirmatives = ["네", "예", "응", "좋", "만들", "마무리", "끝", "그만", "충분", "시작"]
        return affirmatives.contains(where: { answer.contains($0) })
    }

    /// 대화 단계에 맞춰 진행률을 갱신한다.
    ///
    /// 꼬리질문 개수가 대화마다 달라 총 단계 수를 미리 알 수 없다.
    /// 그래서 기준값을 쓰되, 대화가 그보다 길어지면 분모를 함께 늘려
    /// 진행률이 뒤로 가거나 100%에 먼저 도달하는 일이 없게 한다.
    private func updateProgress(questionNumber: Int) {
        let currentStep = questionNumber + 1                    // 닉네임 단계를 한 칸으로 친다
        let total = max(currentStep + 1, Self.baselineTotalSteps)
        let ratio = Float(currentStep) / Float(total)
        progressRelay.accept(min(ratio, Self.maxProgressBeforeComplete))
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

            // 미션 생성으로 이어지는 답변이면 생성 중 메시지를 먼저 표시한다.
            // 마지막 질문의 답변이거나, 마무리 확인에 "예"라고 답한 경우다.
            if isLastQuestion || (awaitingFinishConfirmation && isAffirmative(trimmed)) {
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
                    self.updateProgress(questionNumber: data.questionNumber)

                    // 첫 질문에는 선택지가 없다. 사용자가 예시를 그대로 고르면
                    // 목표가 구체화되지 않아 서버가 placeholder 로만 예시를 내려준다.
                    if let placeholder = data.placeholder, !placeholder.isEmpty {
                        self.inputPlaceholderRelay.accept(placeholder)
                    }

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

        switch data.kind {
        case .completed:
            handleCompleted(data)
        case .goalRejected:
            handleGoalRejected(data)
        case .finishConfirm:
            handleFinishConfirm(data)
        case .nextQuestion:
            handleNextQuestion(data)
        case .unknown:
            // 앱이 모르는 응답이 와도 대화가 멈춘 것처럼 보이지 않게 안내한다.
            appendMessage(ChatMessage(type: .bot, text: "예상하지 못한 응답을 받았어요. 다시 시도해주세요."))
        }
    }

    /// 대화 종료 — 미션 생성 완료
    private func handleCompleted(_ data: ChatbotAnswerResultData) {
        awaitingFinishConfirmation = false
        completedMissions = data.missions ?? []
        progressRelay.accept(1.0)
        appendMessage(ChatMessage(type: .bot, text: "좋아요! 답변을 바탕으로 맞춤 미션을 준비했어요!!!🎉"))
        isCompletedRelay.accept(true)
    }

    /// 목표를 2개 이상 입력한 경우 — 질문을 진행하지 않고 다시 입력받는다.
    /// 세션은 그대로라 같은 sessionId 로 목표만 다시 보내면 된다.
    private func handleGoalRejected(_ data: ChatbotAnswerResultData) {
        let message = data.message ?? "목표를 하나만 입력해주세요!"
        let detected = data.detectedGoals ?? []
        let subtitle = detected.isEmpty ? nil : "입력하신 목표: \(detected.joined(separator: ", "))"

        appendMessage(ChatMessage(
            type: .bot,
            text: message,
            highlightedText: message,
            subtitleText: subtitle,
            isError: true
        ))
    }

    /// 정보가 충분히 모였을 때 — 요약을 보여주고 마무리할지 묻는다.
    private func handleFinishConfirm(_ data: ChatbotAnswerResultData) {
        awaitingFinishConfirmation = true
        isLastQuestion = false

        if let summary = data.summary, !summary.isEmpty {
            appendMessage(ChatMessage(type: .bot, text: summary))
        }

        appendMessage(ChatMessage(
            type: .bot,
            text: data.question ?? "이대로 마무리할까요?",
            suggestions: data.examples ?? []
        ))
    }

    /// 다음 질문 표시 (AI 꼬리질문 또는 투자 가능 시간 고정 질문)
    private func handleNextQuestion(_ data: ChatbotAnswerResultData) {
        guard let question = data.question else { return }

        awaitingFinishConfirmation = false
        isLastQuestion = data.isLast ?? false

        if let questionNumber = data.questionNumber {
            updateProgress(questionNumber: questionNumber)
        }

        appendMessage(ChatMessage(
            type: .bot,
            text: question,
            suggestions: data.examples ?? [],
            subtitleText: isLastQuestion ? "마지막 질문이에요!" : nil
        ))
    }
    
    
    private func appendMessage(_ message: ChatMessage) {
        var msgs = messagesRelay.value
        msgs.append(message)
        messagesRelay.accept(msgs)
    }
}
