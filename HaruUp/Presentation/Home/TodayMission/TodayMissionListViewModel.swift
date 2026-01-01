//
//  TodayMissionListViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TodayMissionListViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTap: Observable<Void>
        let completeTap: Observable<Void>
        let missionSelected: Observable<Int> // mision 선택 이벤트
        let retryRecommend: Observable<Void> // mission 재추천
    }
    
    struct Output {
        let missions: Observable<[MemberMission.MissionDTO]>
        let isLoading: Observable<Bool>
        let errorMessage: Observable<String>
        let missionCompleted: Observable<Void>
        let selectedMissionCount: Observable<Int>
        let selectedIDs: Observable<Set<Int>> // 선택된 Cell을 구분하기 위해
    }
    
    private let missionService: MissionServiceProtocol
    private let interestsService: InterestsService
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let currentMissionsRelay = BehaviorRelay<[MemberMission.MissionDTO]>(value: [])
    private let selectedMissionIDRelay = BehaviorRelay<Set<Int>>(value: [])
    
    private let disposeBag = DisposeBag()
    
    // TODO: test용
    private let userId: Int = 4639152463
    
    init(missionService: MissionServiceProtocol, interestsService: InterestsService) {
        self.missionService = missionService
        self.interestsService = interestsService
        // TODO: 이전 화면에서 사용자의 정보(CoreData or Server)를 가져와서 표시
    }
    
    func transform(input: Input) -> Output {
        let loadingSubject = BehaviorSubject<Bool>(value: false)
        let errorSubject = PublishSubject<String>()
        
        /// 서버로부터 미션 조회
        // 화면 진입 + 새로고침을 하나의 트리거
        let initialLoad = Observable.merge(input.viewDidLoad, input.refreshTap)
        
        initialLoad
            .withUnretained(self)
            .flatMapLatest { [weak self] _ -> Observable<[MemberMission.MissionDTO]> in // 최종 리턴 타입은 [MissionDTO]
                guard let self = self else { return .empty() }
                
                loadingSubject.onNext(true)
                
                return self.resolveMemberInterestId()
                    .flatMap { id -> Single<[MemberMission.MissionDTO]> in
                        return self.missionService.requestRecommendedMissions(memberInterestId: id)
                            .flatMap { response -> Single<[MemberMission.MissionDTO]> in
                                let missions = response.data.missions
                                
                                if !missions.isEmpty {
                                    // 데이터가 있으면 그대로 리턴
                                    return .just(missions)
                                } else {
                                    // 데이터가 비어있으면 두 번째 API 호출 (다중 ID 추천)
                                    // id를 배열 [id] 형태로 감싸서 전달
                                    return self.missionService.requestRecommendedMultipleMissions(memberInterestIds: [id])
                                        .map { multipleResponse in
                                            // MultipleMissionDTO 배열을 MissionDTO 배열로 변환
                                            return multipleResponse.data.missions.map { $0.toMissionDTO() }
                                        }
                                }
                            }
                    }
                    .asObservable()
                    .catch { err in
                        errorSubject.onNext(err.localizedDescription)
                        return .just([])
                    }
                    .do(onDispose: {
                        loadingSubject.onNext(false)
                    })
            }
            .subscribe(onNext: { [weak self] missions in
                loadingSubject.onNext(false)
                self?.currentMissionsRelay.accept(missions)
                self?.selectedMissionIDRelay.accept([])
            })
            .disposed(by: disposeBag)
        
        input.retryRecommend
            .withLatestFrom(Observable.combineLatest(selectedMissionIDRelay, currentMissionsRelay))
            .flatMapLatest { [weak self] (selectedIDs, currentMissions) -> Observable<[MemberMission.MissionDTO]> in
                guard let self = self else { return .empty() }
                loadingSubject.onNext(true)
                
                let selectedMissions = currentMissions.filter { selectedIDs.contains($0.memberMissionId) }
                
                let selectedMissionsIds = selectedMissions.map { $0.memberMissionId }
                
                return self.resolveMemberInterestId()
                    .flatMap { id -> Single<MemberMission.RetryRecommendResponseDTO> in
                        // API 호출: 선택된 미션들의 ID를 보냄
                        self.missionService.retryRecommendMissions(memberInterestId: id, excludeMissionIDs: selectedMissionsIds)
                    }
                    .asObservable()
                    .map { (response: MemberMission.RetryRecommendResponseDTO) -> [MemberMission.MissionDTO] in
                        let newRetryMissions = response.data.missions.first?.data ?? [] // 현재 가장 첫번째 값으로 구현
                        let newMissions = newRetryMissions.map { $0.toMissionDTO() }
                        
                        let needCount = max(0, 5 - selectedMissions.count)
                        let missionsToAdd = Array(newMissions.prefix(needCount))
                        
                        return selectedMissions + missionsToAdd
                    }
                    .catch { err in
                        // 에러 발생 시 최소한 기존 선택된 것들은 유지
                        errorSubject.onNext(err.localizedDescription)
                        return .just(selectedMissions)
                    }
                    .do(onDispose: { loadingSubject.onNext(false) })
            }
            .subscribe(onNext: { [weak self] combinedMissions in
                loadingSubject.onNext(false)
                // 화면 갱신
                self?.currentMissionsRelay.accept(combinedMissions)
            })
            .disposed(by: disposeBag)
        
        /// Mission 선택
        input.missionSelected
            .withLatestFrom(selectedMissionIDRelay) { (id, currentSet) -> Set<Int> in
                var newSet = currentSet
                
                // 이미 있으면 선택 해제
                if newSet.contains(id) {
                    newSet.remove(id)
                } else {
                    if newSet.count < 5 { // 5개 미만일 때만 추가
                        newSet.insert(id)
                    }
                }
                
                return newSet
            }
            .bind(to: selectedMissionIDRelay)
            .disposed(by: disposeBag)
        
        let selectedCount = selectedMissionIDRelay
            .map { $0.count }
            .share(replay: 1)
        
        let missionCompleted = input.completeTap
            .withLatestFrom(selectedMissionIDRelay)
            .map { Array($0) }
            .flatMapLatest { [weak self] ids -> Observable<Void> in
                guard let self = self else { return .empty() }
                
                loadingSubject.onNext(true)
                
                return self.missionService.selectMissions(missionIDs: ids)
                    .asObservable()
                    .map { response -> Bool in
                        return response.success
                    }
                    .do(onNext: { [weak self] isSuccess in
                        loadingSubject.onNext(false)
                        
                        if isSuccess {
                            self?.missionService.markTodayMissionSelected()
                        }
                    }, onError: { _ in
                        loadingSubject.onNext(false)
                    })
                    .catch { error in
                        errorSubject.onNext(error.localizedDescription)
                        return .just(false)
                    }
                    .filter { $0 }
                    .map { _ in () }
            }
            .share(replay: 1)
        
        return Output(
            missions: currentMissionsRelay.asObservable(),
            isLoading: loadingSubject.asObservable(),
            errorMessage: errorSubject.asObservable(),
            missionCompleted: missionCompleted,
            selectedMissionCount: selectedCount,
            selectedIDs: selectedMissionIDRelay.asObservable()
        )
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
