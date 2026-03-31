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
    let type: ChatMessageType
    let text: String
}

// MARK: - ViewModel

final class CurationChatViewModel {

    struct Input {
        let startButtonTapped: Observable<Void>
        let sendButtonTapped: Observable<String>
    }

    struct Output {
        let messages: Driver<[ChatMessage]>
        let currentQuestionIndex: Driver<Int>
        let isCompleted: Driver<Bool>
        let characterName: Driver<String>
        let characterImageName: Driver<String>
    }

    private weak var coordinator: CurationChatCoordinator?
    private let disposeBag = DisposeBag()

    private let characterId: Int
    private let messagesRelay = BehaviorRelay<[ChatMessage]>(value: [])
    private let currentQuestionIndexRelay = BehaviorRelay<Int>(value: -1) // -1 = 시작 전
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)

    private let questions: [String] = [
        "어떠한 것에 관심이 있나요?\n(예시: 영어, 운동, 주식 투자 등)",
        "관심이 생기게 된 계기가 무엇인가요?",
        "해당 관심사에 대한 실력은 1~10단계 중에서 어느 단계인가요?",
        "이루고자 하는 목표 기간이 있나요?",
        "하루에 투자가 가능한 시간은 얼마인가요?",
        "추가 질문이 있으면 작성해주세요!"
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
            characterImageName = "haru_level1"
        case 2:
            characterName = "나루"
            characterImageName = "naru_level1"
        default:
            characterName = "하루"
            characterImageName = "haru_level1"
        }

        let greeting = "안녕하세요! 저는 \(characterName)예요. 여러분에게 가장 적합한 커리큘럼을 설계하기 위해 몇 가지 간단한 질문을 드릴게요."

        // 시작 버튼 탭
        input.startButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                var msgs = self.messagesRelay.value
                msgs.append(ChatMessage(type: .bot, text: greeting))
                self.messagesRelay.accept(msgs)

                // 첫 번째 질문을 약간의 딜레이 후 표시
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.showNextQuestion()
                }
            })
            .disposed(by: disposeBag)

        // 사용자 답변 전송
        input.sendButtonTapped
            .subscribe(onNext: { [weak self] answer in
                guard let self = self else { return }
                let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }

                // 사용자 메시지 추가
                var msgs = self.messagesRelay.value
                msgs.append(ChatMessage(type: .user, text: trimmed))
                self.messagesRelay.accept(msgs)

                self.answers.append(trimmed)

                let currentIdx = self.currentQuestionIndexRelay.value

                if currentIdx < self.questions.count - 1 {
                    // 다음 질문 표시
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.showNextQuestion()
                    }
                } else {
                    // 모든 질문 완료
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        var msgs = self.messagesRelay.value
                        msgs.append(ChatMessage(type: .bot, text: "감사합니다! 답변을 바탕으로 맞춤 커리큘럼을 준비할게요."))
                        self.messagesRelay.accept(msgs)
                        self.isCompletedRelay.accept(true)
                    }
                }
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

        return Output(
            messages: messagesRelay.asDriver(),
            currentQuestionIndex: currentQuestionIndexRelay.asDriver(),
            isCompleted: isCompletedRelay.asDriver(),
            characterName: Driver.just(characterName),
            characterImageName: Driver.just(characterImageName)
        )
    }

    private func showNextQuestion() {
        let nextIndex = currentQuestionIndexRelay.value + 1
        guard nextIndex < questions.count else { return }

        currentQuestionIndexRelay.accept(nextIndex)

        var msgs = messagesRelay.value
        msgs.append(ChatMessage(type: .bot, text: questions[nextIndex]))
        messagesRelay.accept(msgs)
    }
}
