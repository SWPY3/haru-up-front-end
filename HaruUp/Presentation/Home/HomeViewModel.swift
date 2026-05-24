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
        let profileRefresh: Observable<Void>
    }

    struct Output {
        let userInfo: Driver<HomeMemberInfo>
        let rows: Driver<[TodayMissionRow]> /// Driver를 사용한 이유 : UI에서 항상 데이터가 필요
        let showTodayMissionFlow: Signal<Void> /// Signal를 사용한 이유 : 상태를 저장하는 게 아닌 화면을 띄워야하는 명령이 1번만 실행되야함
        let isLoading: Driver<Bool>
        let error: Signal<Error>
        let challengeDay: Driver<Int>
        let challengeList: Driver<[DailyMissionData]>
    }

    private let missionService: MissionServiceProtocol
    private let interestsService: InterestsService
    private let memberService: MemberService

    private let selectedMissionsRelay = BehaviorRelay<[Mission]>(value: [])
    var currentMissionIDs: [Int] {
        return selectedMissionsRelay.value.map { $0.id }
    }

    // 로딩/에러(나중에 서버 붙일 때 그대로 확장 가능)
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private let challengeDataRelay = PublishRelay<[MemberMission.ChallengeDataDTO]>()
    private let showMissionFlowRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()

    init(missionService: MissionServiceProtocol, interestsService: InterestsService, memberService: MemberService) {
        self.missionService = missionService
        self.interestsService = interestsService
        self.memberService = memberService
    }
    
    func transform(input: Input) -> Output {
        
        // 1) 초기 로드: viewDidAppear 시 미션 리스트 조회
        let initialMissionResult = input.viewDidAppear
            .take(1)
            .flatMapLatest { [weak self] _ -> Observable<[Mission]> in
                guard let self else { return .empty() }
                return self.loadSelectedMissions()
            }
            .share(replay: 1, scope: .whileConnected)
        
        // 2) 미션이 비어있으면 → 플로우 표시
        initialMissionResult
            .filter { $0.isEmpty }
            .map { _ in () }
            .bind(to: showMissionFlowRelay)
            .disposed(by: disposeBag)
        
        // 3) 미션이 있으면 → 바로 표시
        initialMissionResult
            .filter { !$0.isEmpty }
            .bind(to: selectedMissionsRelay)
            .disposed(by: disposeBag)
        
        // 4) 외부에서 리로드 요청이 온 경우 (미션 선택 완료 후)
        input.reload
            .flatMapLatest { [weak self] _ -> Observable<[Mission]> in
                guard let self else { return .empty() }
                return self.loadSelectedMissions()
            }
            .bind(to: selectedMissionsRelay)
            .disposed(by: disposeBag)
        
        // 5) 챌린지 데이터 로드 (초기 로드 완료 후 또는 리로드 시)
        let loadChallengeTrigger = Observable.merge(
            initialMissionResult.map { _ in () },
            input.reload
        )
        
        loadChallengeTrigger
            .flatMapLatest { [weak self] _ -> Observable<[MemberMission.ChallengeDataDTO]> in
                guard let self else { return .empty() }
                return self.missionService.fetchChallengeDate().asObservable()
                    .map { $0.data }
                    .catch { error in
                        print("챌린지 로드 실패: \(error)")
                        return .just([])
                    }
            }
            .bind(to: challengeDataRelay)
            .disposed(by: disposeBag)
        
        // 6) 유저 정보 로드
        let userInfoTrigger = Observable.merge(
            initialMissionResult.map { _ in () },
            input.reload,
            input.profileRefresh
        )
        
        let userInfo = userInfoTrigger
            .flatMapLatest { [weak self] _ -> Observable<HomeMemberInfo> in
                guard let self = self else { return .empty() }
                
                return self.memberService.fetchHomeMemberInfo()
                    .map { response -> HomeMemberInfo in
                        
                        let data = response.data.first
                        let interest = data?.interests.first?.first
                        
                        return HomeMemberInfo(
                            characterId: data?.characterId ?? 1,
                            level: data?.levelNumber ?? 1,
                            nickname: data?.nickname ?? "하루",
                            totalExp: data?.totalExp ?? 1000,
                            maxExp: data?.maxExp ?? 1000,
                            currentExp: data?.currentExp ?? 0,
                            interest: interest ?? ""
                        )
                    }
                    .asObservable()
                    .catch { error in
                        print("유저 정보 로드 실패: \(error)")
                        return .just(HomeMemberInfo.empty)
                    }
            }
            .asDriver(onErrorJustReturn: HomeMemberInfo.empty)
        
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
                    return sortedMissions.map { .mission($0) } + [.add]
                } else {
                    return sortedMissions.map { .mission($0) }
                }
            }
            .asDriver(onErrorJustReturn: [.empty])
        
        let challengeCount = challengeDataRelay
            .map { data -> Int in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.timeZone = TimeZone.current
                let todayString = formatter.string(from: Date())
                
                let sortedData = data.sorted { $0.targetDate > $1.targetDate }
                
                var streak = 0
                
                for day in sortedData {
                    if day.targetDate == todayString {
                        if day.isCompleted {
                            streak += 1
                        } else {
                            continue
                        }
                    } else {
                        if day.isCompleted {
                            streak += 1
                        } else {
                            break
                        }
                    }
                }
                
                return streak
            }
            .asDriver(onErrorJustReturn: 0)
        
        let challengeList = challengeDataRelay
            .map { [weak self] data -> [DailyMissionData] in
                guard let self = self, !data.isEmpty else { return [] }
                return self.processChallengeList(data: data)
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            userInfo: userInfo,
            rows: rows,
            showTodayMissionFlow: showMissionFlowRelay.asSignal(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            challengeDay: challengeCount,
            challengeList: challengeList
        )
    }
    
    private func loadSelectedMissions() -> Observable<[Mission]> {
        return Observable.just(())
            .do(
                onSubscribe: { [weak self] in self?.loadingRelay.accept(true) },
                onDispose:   { [weak self] in self?.loadingRelay.accept(false) }
            )
            .flatMap { [weak self] _ -> Observable<MemberMission.FetchMissionResponseDTO> in
                guard let self = self else { return .empty() }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let todayString = formatter.string(from: Date())

                let status: [MemberMission.MissionStatusType] = [.completed, .active]

                // memberInterestId를 nil로 전달 → 백엔드에서 오늘 전체 미션 반환
                return self.missionService.fetchMissionList(
                    memberInterestId: nil,
                    targetDate: todayString,
                    status: status
                ).asObservable()
            }
            .map { response -> [Mission] in
                let missions = response.data
                
                return missions.map { mission in
                    Mission(
                        id: mission.id,
                        title: mission.missionContent,
                        description: mission.missionDescription,
                        difficulty: MissionDifficultyModel.from(difficulty: mission.difficulty),
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
        if let saved = UserDefaultsManager.shared.selectedMemberInterestId {
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
                
                UserDefaultsManager.shared.selectedMemberInterestId = id // UserDefaults 값 업데이트
                return id
            }
    }
}

extension HomeViewModel {
    /// 서버 데이터를 받아 "첫 달성일"부터 시작하는 7일치 UI 데이터를 만듭니다.
    private func processChallengeList(data: [MemberMission.ChallengeDataDTO]) -> [DailyMissionData] {
        print("processChallengeList")
        // 1. 날짜 오름차순 정렬 (과거 -> 미래)
        let sortedData = data.sorted { $0.targetDate < $1.targetDate }
        
        print("sortedData: \(sortedData)")
        
        // 2. 가장 처음 성공한 날짜 찾기
        guard let firstCompletedIndex = sortedData.firstIndex(where: { $0.isCompleted }),
              let startDate = DateHelper.stringToDate(sortedData[firstCompletedIndex].targetDate) else {
            
            // 성공한 날이 하루도 없으면? -> 그냥 받은 데이터 그대로 변환하거나 빈 상태 리턴
            // (여기서는 조회 기간 첫날부터 보여주는 것으로 처리)
            return sortedData.map { dto in
                DailyMissionData(dayString: DateHelper.getDayString(from: dto.targetDate), status: dto.isCompleted ? .completed : .failed)
            }
        }
        
        // 3. 서버 데이터를 딕셔너리로 변환 (빠른 조회를 위해)
        // Key: "yyyy-MM-dd", Value: isCompleted
        let serverDataMap = Dictionary(uniqueKeysWithValues: data.map { ($0.targetDate, $0.isCompleted) })
        
        // 4. 시작 날짜(startDate)부터 7일간의 날짜 배열 생성 및 매핑
        var result: [DailyMissionData] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            // startDate + i일 계산
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let dateString = DateHelper.dateToString(date) // yyyy-MM-dd
                
                // 5. 서버에 해당 날짜 데이터가 있는지 확인
                var status: MissionChallengeStatus = .none
                
                if let isCompleted = serverDataMap[dateString] {
                    // 서버에 데이터가 있으면 성공/실패 여부 따짐
                    status = isCompleted ? .completed : .failed
                } else {
                    // 서버에 데이터가 없으면(미래 날짜거나 범위 밖) -> 빈 값 처리
                    status = .none
                }
                
                // 요일 문자열 구하기 (월, 화, 수...)
                let dayLabel = DateHelper.getDayString(from: date)
                
                result.append(DailyMissionData(dayString: dayLabel, status: status))
            }
        }
        
        return result
    }
}
