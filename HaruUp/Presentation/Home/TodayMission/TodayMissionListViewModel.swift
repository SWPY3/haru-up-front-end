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
        let retryCount: Observable<Int>
        let isLoading: Observable<Bool>
        let errorMessage: Observable<String>
        let missionCompleted: Observable<Void>
        let selectedMissionCount: Observable<Int>
        let selectedIDs: Observable<Set<Int>> // 선택된 Cell을 구분하기 위해
    }
    
    private let missionService: MissionServiceProtocol
    private let interestsService: InterestsService
    
    private let retryCountRelay = PublishRelay<Int>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let currentMissionsRelay = BehaviorRelay<[MemberMission.MissionDTO]>(value: [])
    private let selectedMissionIDRelay = BehaviorRelay<Set<Int>>(value: [])
    
    private let disposeBag = DisposeBag()

    // 변경 불가능한(이미 선택된) 미션 ID들을 저장할 Set
    private let fixedMissionIDs: Set<Int>

    /// 챗봇 플로우: 이미 생성된 미션을 API 재호출 없이 직접 주입
    private let chatbotMissions: [MemberMission.MissionDTO]?

    init(missionService: MissionServiceProtocol,
         interestsService: InterestsService,
         preSelectedMissionIDs: [Int] = [],
         chatbotMissions: [ChatbotMissionDto]? = nil) {

        self.missionService = missionService
        self.interestsService = interestsService
        self.fixedMissionIDs = Set(preSelectedMissionIDs)
        self.chatbotMissions = chatbotMissions?.map { dto in
            MemberMission.MissionDTO(
                memberMissionId: dto.id,
                missionStatus: "READY",
                content: dto.missionContent,
                directFullPath: [],
                difficulty: dto.difficulty,
                expEarned: dto.expEarned,
                targetDate: "",
                missionDescription: dto.missionDescription
            )
        }
        self.selectedMissionIDRelay.accept(self.fixedMissionIDs)
    }
    
    func transform(input: Input) -> Output {
        let loadingSubject = BehaviorSubject<Bool>(value: false)
        let errorSubject = PublishSubject<String>()
        
        /// 서버로부터 미션 조회
        // 챗봇 완료 직후 첫 진입은 answer 응답의 missions를 그대로 표시하고 추천 API를 중복 호출하지 않는다.
        let injectedInitialLoad = input.viewDidLoad
            .take(1)
            .compactMap { [weak self] _ in self?.chatbotMissions }

        // 일반 진입/재진입 및 새로고침은 현재 미션 소스에 맞춰 서버에서 재조회한다.
        let apiInitialLoad = input.viewDidLoad
            .take(1)
            .filter { [weak self] _ in self?.chatbotMissions == nil }

        let apiLoad = Observable.merge(apiInitialLoad, input.refreshTap)
            .flatMapLatest { [weak self] _ -> Observable<[MemberMission.MissionDTO]> in
                guard let self else { return .empty() }
                loadingSubject.onNext(true)

                return self.resolveMissionSource()
                    .flatMap { source in
                        self.missionService.requestRecommendedMultipleMissions(
                            memberInterestIds: source.recommendationMemberInterestIds
                        )
                        .map { response in
                            self.retryCountRelay.accept(response.data.retryCount)
                            return Self.recommendedMissionDTOs(from: response, source: source)
                        }
                    }
                    .asObservable()
                    .catch { err in
                        errorSubject.onNext(err.localizedDescription)
                        return .just([])
                    }
                    .do(onDispose: { loadingSubject.onNext(false) })
            }

        Observable.merge(injectedInitialLoad, apiLoad)
            .subscribe(onNext: { [weak self] missions in
                guard let self = self else { return }
                loadingSubject.onNext(false)
                let filtered = missions.filter { !self.fixedMissionIDs.contains($0.memberMissionId) }
                self.currentMissionsRelay.accept(filtered)
                self.selectedMissionIDRelay.accept(self.fixedMissionIDs)
            })
            .disposed(by: disposeBag)
        
        input.retryRecommend
            .withLatestFrom(Observable.combineLatest(selectedMissionIDRelay, currentMissionsRelay))
            .flatMapLatest { [weak self] (selectedIDs, currentMissions) -> Observable<[MemberMission.MissionDTO]> in
                guard let self = self else { return .empty() }
                loadingSubject.onNext(true)
                
                let selectedMissions = currentMissions.filter { selectedIDs.contains($0.memberMissionId) }
                let selectedMissionsIds = selectedMissions.map { $0.memberMissionId }
                
                return self.resolveMissionSource()
                    .flatMap { source -> Single<(MissionSource, MemberMission.RetryRecommendResponseDTO)> in
                        let excludeMissionIDs = source.shouldSendRetryExcludeMissionIds ? selectedMissionsIds : nil
                        return self.missionService.retryRecommendMissions(
                            memberInterestId: source.retryMemberInterestId,
                            excludeMissionIDs: excludeMissionIDs
                        )
                        .map { (source, $0) }
                    }
                    .asObservable()
                    .map { (source, response) -> [MemberMission.MissionDTO] in
                        let data = response.data
                        
                        self.retryCountRelay.accept(data.retryCount)
                        
                        let newMissions = Self.retryMissionDTOs(from: response, source: source)
                        
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
                guard let self else { return }
                
                loadingSubject.onNext(false)
                // 화면 갱신
                self.currentMissionsRelay.accept(combinedMissions)
                self.selectedMissionIDRelay.accept(self.fixedMissionIDs)
            })
            .disposed(by: disposeBag)
        
        /// Mission 선택
        input.missionSelected
            .withLatestFrom(selectedMissionIDRelay) { [weak self] (clickedID, currentSet) -> Set<Int> in
                guard let self = self else { return currentSet }
                
                if self.fixedMissionIDs.contains(clickedID) {
                    return currentSet
                }
                
                var newSet = currentSet
                
                newSet.formUnion(self.fixedMissionIDs)
                
                if newSet.contains(clickedID) {
                    newSet.remove(clickedID)
                } else {
                    if newSet.count < 5 {
                        newSet.insert(clickedID)
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
            .map { [weak self] allSelectedIDs -> [Int] in
                guard let self = self else { return [] }
                
                let newSelectedIDs = allSelectedIDs.subtracting(self.fixedMissionIDs)
                
                return Array(newSelectedIDs)
            }
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
            retryCount: retryCountRelay.asObservable(),
            isLoading: loadingSubject.asObservable(),
            errorMessage: errorSubject.asObservable(),
            missionCompleted: missionCompleted,
            selectedMissionCount: selectedCount,
            selectedIDs: selectedMissionIDRelay.asObservable()
        )
    }
    
    private func resolveMissionSource() -> Single<MissionSource> {
        if chatbotMissions != nil || UserDefaultsManager.shared.usesChatbotGoalMissions {
            return .just(.chatbot)
        }

        if let saved = UserDefaultsManager.shared.selectedMemberInterestId {
            return .just(MissionSource(memberInterestIds: [saved]))
        }

        // 없을 시 서버에 요청
        return interestsService.fetchInterests()
            .map { dto -> MissionSource in
                let source = MissionSource(memberInterestIds: dto.interests.map(\.memberInterestId))

                switch source {
                case .chatbot:
                    UserDefaultsManager.shared.usesChatbotGoalMissions = true
                case .interest(let ids):
                    UserDefaultsManager.shared.selectedMemberInterestId = ids.first
                }

                return source
            }
    }

    private static func recommendedMissionDTOs(
        from response: MemberMission.RecommendMultipleResponseDTO,
        source: MissionSource
    ) -> [MemberMission.MissionDTO] {
        let targetIDs = Set(source.recommendationMemberInterestIds)

        return response.data.missions
            .filter { targetIDs.contains($0.memberInterestId) }
            .flatMap { group in
                group.data.map { $0.toMissionDTO() }
            }
    }

    private static func retryMissionDTOs(
        from response: MemberMission.RetryRecommendResponseDTO,
        source: MissionSource
    ) -> [MemberMission.MissionDTO] {
        response.data.missions
            .first { $0.memberInterestId == source.retryMemberInterestId }?
            .data
            .map { $0.toMissionDTO() } ?? []
    }
}
