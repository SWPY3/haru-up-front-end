//
//  CurationChatViewModel.swift
//  HaruUp
//
//  Created on 2026/03/30.
//

import UIKit
import RxSwift
import RxCocoa

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

    init(
        type: ChatMessageType,
        text: String,
        highlightedText: String? = nil,
        suggestions: [String] = [],
        subtitleText: String? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.text = text
        self.highlightedText = highlightedText
        self.suggestions = suggestions
        self.subtitleText = subtitleText
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

        // 화면 표시 시 자동 시작
        input.viewDidAppear
            .take(1)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.startChatbot()
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
                self.coordinator?.didFinishChat(missions: self.completedMissions)
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
        startChatbot()   // ← API 다시 호출
    }

    // MARK: - Private
    private func handleUserAnswer(_ answer: String) {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let sessionId = sessionId else { return }

        // 1. 사용자 메시지 화면에 추가
        appendMessage(ChatMessage(type: .user, text: trimmed))
        
        // 2. 로딩 시작
        isLoadingRelay.accept(true)
        
        // 3. 백엔드에 답변 전송
        chatbotService.answer(sessionId: sessionId, answer: trimmed)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    self?.isLoadingRelay.accept(false)
                    self?.handleAnswerResponse(response.data)
                },
                onFailure: { [weak self] error in
                    self?.isLoadingRelay.accept(false)
                    self?.appendMessage(ChatMessage(type: .bot, text: "오류가 발생했어요. 다시 시도해주세요."))
                }
            )
            .disposed(by: disposeBag)
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
