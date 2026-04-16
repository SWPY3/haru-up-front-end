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

// MARK: - Question Data

struct ChatQuestion {
    let text: String
    let suggestions: [String]
    let subtitleText: String?
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
        let characterName: Driver<String>
        let characterImageName: Driver<String>
        let prefillText: Driver<String>
    }

    private weak var coordinator: CurationChatCoordinator?
    private let disposeBag = DisposeBag()

    private let characterId: Int
    private let messagesRelay = BehaviorRelay<[ChatMessage]>(value: [])
    private let currentQuestionIndexRelay = BehaviorRelay<Int>(value: -1)
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)
    private let prefillTextRelay = PublishRelay<String>()

    private let questions: [ChatQuestion] = [
        ChatQuestion(
            text: "어떤 목표를 이루고 싶으신가요?\n도전하고 싶은 목표를 선택하거나 직접 입력해주세요.",
            suggestions: ["🏋 운동 습관 만들기", "📗 오픽 AL 취득", "💰 주식 투자 시작", "🏃 체중 5kg 감량", "🚭 금연하기"],
            subtitleText: nil
        ),
        ChatQuestion(
            text: "관심이 생기게 된 계기가 무엇인가요?",
            suggestions: [],
            subtitleText: "(AI가 생성한 질문)"
        ),
        ChatQuestion(
            text: "해당 관심사에 대한 실력은 1~10단계 중에서 어느 단계인가요?",
            suggestions: [],
            subtitleText: "(AI가 생성한 질문)"
        ),
        ChatQuestion(
            text: "이루고자 하는 목표 기간이 있나요?",
            suggestions: ["1개월", "3개월", "6개월", "1년"],
            subtitleText: "(AI가 생성한 질문)"
        ),
        ChatQuestion(
            text: "하루에 투자가 가능한 시간은 얼마인가요?",
            suggestions: ["30분", "1시간", "2시간", "3시간 이상"],
            subtitleText: "(AI가 생성한 질문)"
        ),
        ChatQuestion(
            text: "추가 질문이 있으면 작성해주세요!",
            suggestions: [],
            subtitleText: nil
        )
    ]

    private(set) var answers: [String] = []

    init(coordinator: CurationChatCoordinator, characterId: Int) {
        self.coordinator = coordinator
        self.characterId = characterId
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
                
                self.showNextQuestion()
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
                self.coordinator?.didFinishChat(answers: self.answers)
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
            characterName: Driver.just(characterName),
            characterImageName: Driver.just(characterImageName),
            prefillText: prefillTextRelay.asDriver(onErrorJustReturn: "")
        )
    }
    
    // 처음부터 다시 시작하기 로직
    func restartChat() {
        messagesRelay.accept([])
        answers = []
        currentQuestionIndexRelay.accept(-1)
        isCompletedRelay.accept(false)
        showNextQuestion()
        }

    // MARK: - Private
    private func handleUserAnswer(_ answer: String) {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var msgs = messagesRelay.value
        msgs.append(ChatMessage(type: .user, text: trimmed))
        messagesRelay.accept(msgs)

        answers.append(trimmed)

        let currentIdx = currentQuestionIndexRelay.value

        if currentIdx < questions.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.showNextQuestion()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                var msgs = self.messagesRelay.value
                msgs.append(ChatMessage(
                    type: .bot,
                    text: "감사합니다! 답변을 바탕으로 맞춤 커리큘럼을 준비할게요."
                ))
                self.messagesRelay.accept(msgs)
                self.isCompletedRelay.accept(true)
            }
        }
    }

    private func showNextQuestion() {
        let nextIndex = currentQuestionIndexRelay.value + 1
        guard nextIndex < questions.count else { return }

        currentQuestionIndexRelay.accept(nextIndex)

        let question = questions[nextIndex]
        var msgs = messagesRelay.value
        msgs.append(ChatMessage(
            type: .bot,
            text: question.text,
            suggestions: question.suggestions,
            subtitleText: question.subtitleText
        ))
        messagesRelay.accept(msgs)
    }
}
