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
    
    private let disposeBag = DisposeBag()

    init(missionService: MissionServiceProtocol, interestsService: InterestsService, memberService: MemberService) {
        self.missionService = missionService
        self.interestsService = interestsService
        self.memberService = memberService
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

        let loadTrigger = Observable.merge(initialLoad, reloadLoad)
        
        // A와 B 둘 중 하나라도 발생하면 데이터 로드
        loadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Mission]> in
                guard let self else { return .empty() }
                return self.loadSelectedMissions()
            }
            .bind(to: selectedMissionsRelay)
            .disposed(by: disposeBag)
        

        loadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[MemberMission.ChallengeDataDTO]> in
                guard let self else { return .empty() }
                return self.missionService.fetchChallengeDate().asObservable()
                    .map { $0.data } // Response에서 data 배열만 추출
                    .catch { error in
                        print("챌린지 로드 실패: \(error)")
                        return .just([]) // 에러 시 빈 배열 반환하여 스트림 유지
                    }
            }
            .bind(to: challengeDataRelay)
            .disposed(by: disposeBag)
        
        let userInfoTrigger = Observable.merge(
            loadTrigger,
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
                            currentExp: data?.currentExp ?? 500,
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
                    // 정렬된 미션들 뒤에 .add 버튼 붙이기
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
                    // A. 만약 조회한 데이터가 '오늘'인 경우
                    if day.targetDate == todayString {
                        if day.isCompleted {
                            // 오늘 완료했으면 카운트 증가
                            streak += 1
                        } else {
                            // [핵심] 오늘 아직 안 했으면, 연속 기록이 깨진 게 아니므로
                            // 카운트는 안 하고 다음(어제)으로 넘어감
                            continue
                        }
                    }
                    // B. 오늘이 아닌 과거 날짜인 경우
                    else {
                        if day.isCompleted {
                            streak += 1
                        } else {
                            // 과거에 안 한 날이 나오면 바로 연속 기록 종료
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
            showTodayMissionFlow: showTodayMissionFlow,
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            challengeDay: challengeCount,
            challengeList: challengeList
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
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let todayString = formatter.string(from: Date())
                
                let status: [MemberMission.MissionStatusType] = [.completed, .active]
                
                return self.missionService.fetchMissionList(
                    memberInterestId: id,
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
