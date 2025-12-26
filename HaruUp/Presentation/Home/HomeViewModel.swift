//
//  HomeViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import RxSwift
import RxCocoa

final class HomeViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let viewDidAppear: Observable<Void>
    }

    struct Output {
        let rows: Driver<[TodayMissionRow]> /// Driver를 사용한 이유 : UI에서 항상 데이터가 필요
        let showTodayMissionFlow: Signal<Void> /// Signal를 사용한 이유 : 상태를 저장하는 게 아닌 화면을 띄워야하는 명령이 1번만 실행되야함
        let isLoading: Driver<Bool>
        let error: Signal<Error>
    }

    private let missionService: MissionServiceProtocol
    private let disposeBag = DisposeBag()

    private let selectedMissionsRelay = BehaviorRelay<[Mission]>(value: [])

    // 로딩/에러(나중에 서버 붙일 때 그대로 확장 가능)
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()

    init(missionService: MissionServiceProtocol) {
        self.missionService = missionService
    }

    func transform(input: Input) -> Output {
        Observable.merge(input.viewDidLoad)
            .flatMapLatest { [weak self] _ -> Observable<[Mission]> in
                guard let self else { return .empty() }
                return self.loadSelectedMissions()
            }
            .bind(to: selectedMissionsRelay)
            .disposed(by: disposeBag)

        let rows = selectedMissionsRelay
            .map { selected -> [TodayMissionRow] in
                if selected.isEmpty {
                    return [.empty]
                } else if selected.count < 5 {
                    return selected.map { .mission($0) } + [.add]
                } else {
                    return selected.map { .mission($0) }
                }
            }
            .asDriver(onErrorJustReturn: [.empty])

        let showTodayMissionFlow = input.viewDidAppear
            .take(1) // 앱 실행후 한번만 확인
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                return self.missionService.needShowTodayMissionFlow().asObservable()
            }
            .filter { $0 }
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            rows: rows,
            showTodayMissionFlow: showTodayMissionFlow,
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }

    // MARK: - Temp loader (서버 붙이면 여기만 교체)
    private func loadSelectedMissions() -> Observable<[Mission]> {
        return missionService.fetchMissionList()
            .asObservable()
            .do(
                onSubscribe: { [weak self] in self?.loadingRelay.accept(true) },
                onDispose:   { [weak self] in self?.loadingRelay.accept(false) }
            )
            .map { [weak self] response -> [Mission] in
                let missions = response.data

                return missions.map { mission in
                    Mission(
                        title: mission.missionContent,
                        difficulty: MissionDifficultyModel(rawValue: mission.difficulty) ?? .low,
                        exp: mission.expEarned
                    )
                }
            }
            .catch { [weak self] err in
                self?.errorRelay.accept(err)
                return .just([])
            }
    }
}
