//
//  PersonalitySelectViewModel.swift
//  HaruUp
//

import Foundation
import RxSwift
import RxCocoa

final class PersonalitySelectViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let personalitySelected: Observable<Int>      // 목록에서 고른 인덱스
        let nextButtonTapped: Observable<Void>
    }

    struct Output {
        let personalities: Driver<[PersonalityData]>
        let selectedIndex: Driver<Int?>
        let isNextEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
    }

    /// 서버 목록을 못 받았을 때 쓰는 기본 선택지.
    /// 성격을 못 고르면 큐레이션 자체를 진행할 수 없으므로 화면을 비워 두지 않는다.
    /// 서버가 고르지 않은 회원에게 적용하는 기본값과 같은 순서로 둔다.
    static let fallbackPersonalities: [PersonalityData] = [
        PersonalityData(code: "WARM_FRIEND", label: "따뜻하게 응원하며 함께 가는 친구"),
        PersonalityData(code: "CLEAR_COACH", label: "명확한 계획으로 이끌어주는 코치")
    ]

    private weak var coordinator: PersonalitySelectCoordinator?
    private let chatbotService: ChatbotService
    private let disposeBag = DisposeBag()

    private let personalitiesRelay = BehaviorRelay<[PersonalityData]>(value: [])
    private let selectedIndexRelay = BehaviorRelay<Int?>(value: nil)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    init(coordinator: PersonalitySelectCoordinator, chatbotService: ChatbotService) {
        self.coordinator = coordinator
        self.chatbotService = chatbotService
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.loadPersonalities()
            })
            .disposed(by: disposeBag)

        input.personalitySelected
            .subscribe(onNext: { [weak self] index in
                self?.selectedIndexRelay.accept(index)
            })
            .disposed(by: disposeBag)

        input.nextButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.submitSelection()
            })
            .disposed(by: disposeBag)

        return Output(
            personalities: personalitiesRelay.asDriver(),
            selectedIndex: selectedIndexRelay.asDriver(),
            isNextEnabled: selectedIndexRelay.map { $0 != nil }.asDriver(onErrorJustReturn: false),
            isLoading: isLoadingRelay.asDriver()
        )
    }

    // MARK: - Private

    private func loadPersonalities() {
        isLoadingRelay.accept(true)

        chatbotService.personalityList()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let self = self else { return }
                    self.isLoadingRelay.accept(false)

                    let list = response.data ?? []
                    self.personalitiesRelay.accept(list.isEmpty ? Self.fallbackPersonalities : list)
                },
                onFailure: { [weak self] _ in
                    // 목록을 못 받아도 선택은 할 수 있어야 한다
                    self?.isLoadingRelay.accept(false)
                    self?.personalitiesRelay.accept(Self.fallbackPersonalities)
                }
            )
            .disposed(by: disposeBag)
    }

    private func submitSelection() {
        guard let index = selectedIndexRelay.value else { return }
        let personalities = personalitiesRelay.value
        guard index < personalities.count else { return }

        let code = personalities[index].code
        isLoadingRelay.accept(true)

        chatbotService.selectPersonality(code)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] _ in
                    self?.isLoadingRelay.accept(false)
                    self?.coordinator?.didSelectPersonality()
                },
                onFailure: { [weak self] _ in
                    // 저장에 실패해도 큐레이션은 진행한다.
                    // 서버가 성격 미선택 회원에게 기본값을 적용하므로 대화가 막히지는 않는다.
                    self?.isLoadingRelay.accept(false)
                    self?.coordinator?.didSelectPersonality()
                }
            )
            .disposed(by: disposeBag)
    }
}
