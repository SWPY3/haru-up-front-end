//
//  HomeViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let viewDidAppear: Observable<Void>
        let reload: Observable<Void>
    }

    struct Output {
        let rows: Driver<[TodayMissionRow]> /// Driver를 사용한 이유 : UI에서 항상 데이터가 필요
        let showTodayMissionFlow: Signal<Void> /// Signal를 사용한 이유 : 상태를 저장하는 게 아닌 화면을 띄워야하는 명령이 1번만 실행되야함
        let isLoading: Driver<Bool>
        let error: Signal<Error>
    }

    private let missionService: MissionServiceProtocol
    private let interestsService: InterestsService

    private let selectedMissionsRelay = BehaviorRelay<[Mission]>(value: [])

    // 로딩/에러(나중에 서버 붙일 때 그대로 확장 가능)
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()

    init(missionService: MissionServiceProtocol, interestsService: InterestsService) {
        self.missionService = missionService
        self.interestsService = interestsService
    }

    func transform(input: Input) -> Output {
        // 1) 오늘 미션 플로우 필요 여부를 1번만 확인해서 공유
        let needShow = input.viewDidAppear
            .take(1)
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                return self.missionService.needShowTodayMissionFlow().asObservable()
            }
            .share(replay: 1, scope: .whileConnected)
        
        // 2) 플로우 띄우기
        let showTodayMissionFlow = needShow
            .filter { $0 }
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())
        
        // 3) 데이터 로드 로직
        // A: 미션 플로우가 필요 없는 경우
        let initialLoad = needShow
            .filter { !$0 }
            .map { _ in () }
        
        // B: 외부에서 리로드 요청이 온 경우 (미션 선택 완료 후)
        let reloadLoad = input.reload
        
        // A와 B 둘 중 하나라도 발생하면 데이터 로드
        Observable.merge(initialLoad, reloadLoad)
            .flatMapLatest { [weak self] _ -> Observable<[Mission]> in
                guard let self else { return .empty() }
                return self.loadSelectedMissions()
            }
            .bind(to: selectedMissionsRelay)
            .disposed(by: disposeBag)

        let rows = selectedMissionsRelay
            .map { selected -> [TodayMissionRow] in
                let sortedMissions = selected.sorted { lhs, rhs in
                    if lhs.isCompleted != rhs.isCompleted {
                        return !lhs.isCompleted
                    }
                    
                    return lhs.difficulty.rawValue > rhs.difficulty.rawValue
                }
                
                if sortedMissions.isEmpty {
                    return [.empty]
                } else if sortedMissions.count < 5 {
                    // 정렬된 미션들 뒤에 .add 버튼 붙이기
                    return sortedMissions.map { .mission($0) } + [.add]
                } else {
                    return sortedMissions.map { .mission($0) }
                }
            }
            .asDriver(onErrorJustReturn: [.empty])

        return Output(
            rows: rows,
            showTodayMissionFlow: showTodayMissionFlow,
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }
    
    private func loadSelectedMissions() -> Observable<[Mission]> {
        return resolveMemberInterestId()
            .asObservable()
            .do(
                onSubscribe: { [weak self] in self?.loadingRelay.accept(true) },
                onDispose:   { [weak self] in self?.loadingRelay.accept(false) }
            )
            .flatMap { [weak self] id -> Observable<MemberMission.FetchMissionResponseDTO> in
                guard let self = self else { return .empty() }
                
                return self.missionService.fetchMissionList(memberInterestId: id).asObservable()
            }
            .map { response -> [Mission] in
                let missions = response.data
                
                return missions.map { mission in
                    Mission(
                        id: mission.id,
                        title: mission.missionContent,
                        difficulty: MissionDifficultyModel(rawValue: mission.difficulty) ?? .low,
                        exp: mission.expEarned,
                        isCompleted: mission.missionStatus == "COMPLETED"
                    )
                }
            }
            .catch { [weak self] err in
                self?.errorRelay.accept(err)
                return .just([])
            }
    }
    
    private func resolveMemberInterestId() -> Single<Int> {
        // UserDefaults에 저장된 값 사용
        if let saved = UserStorage.shared.selectedMemberInterestId {
            return .just(saved)
        }
        
        // 없을 시 서버에 요청 후 데이터 값 저장
        return interestsService.fetchInterests()
            .map { [weak self] dto in
                guard let id = dto.interests.first?.memberInterestId else {
                    throw NSError(domain: "Interests",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "관심사가 없습니다."])
                }
                
                UserStorage.shared.selectedMemberInterestId = id // UserDefaults 값 업데이트
                return id
            }
    }
}
