//
//  HistoryViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HistoryViewModel {
    
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let monthChanged: Observable<Date>
        let growthChartRefresh: Observable<Void>
        let daySelected: Observable<(day: Int, hasCompleted: Bool)>
    }
    
    // MARK: - Output
    struct Output {
        let monthTitle: Driver<String>
        let attendanceDays: Driver<Int>
        let completedMissions: Driver<Int>
        let dailyMissions: Driver<[DailyMission]>
        let selectedDayMissions: Driver<[HistoryModel.Mission]>
        let growthChart: Driver<[HistoryModel.GrowthData]>
        let isLoading: Driver<Bool>
        let isMissionLoading: Driver<Bool>  // 추가: 상세 미션 로딩 상태
        let error: Driver<String>
    }
    
    // MARK: - Properties
    private let missionService: MissionServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(missionService: MissionServiceProtocol) {
        self.missionService = missionService
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)
        let isMissionLoading = BehaviorRelay<Bool>(value: false)
        let error = PublishRelay<String>()
        let dailyMissions = BehaviorRelay<MonthlyMissionSummary?>(value: nil)
        let selectedDayMissions = BehaviorRelay<[HistoryModel.Mission]>(value: [])
        let currentMonth = BehaviorRelay<Date>(value: Date())
        let growthData = BehaviorRelay<[HistoryModel.GrowthData]>(value: [])
        
        // 날짜 선택 시 상세 미션 조회 (완료된 미션이 있는 경우에만)
        input.daySelected
            .do(onNext: { _ in
                selectedDayMissions.accept([])  // 초기화
            })
            .filter { $0.hasCompleted }  // 완료된 미션이 있는 경우만 API 호출
            .do(onNext: { _ in isMissionLoading.accept(true) })
            .withLatestFrom(currentMonth) { ($0, $1) }
            .flatMapLatest { [weak self] (dayInfo, month) -> Observable<[HistoryModel.Mission]> in
                guard let self = self else { return .empty() }
                
                guard let id = UserDefaultsManager.shared.selectedMemberInterestId else {
                    return .empty() // TODO: 해결 필요
                }
                let targetDate = self.formatDate(from: month, day: dayInfo.day)
                let status: [MemberMission.MissionStatusType] = [.completed]
                
                return self.missionService.fetchMissionList(memberInterestId: id, targetDate: targetDate, status: status)
                    .asObservable()
                    .map { response -> [HistoryModel.Mission] in
                        guard response.success else {
                            if let errorMessage = response.errorMessage {
                                error.accept(errorMessage)
                            }
                            return []
                        }
                        return response.data.map { dto in
                            HistoryModel.Mission(
                                title: dto.missionContent,
                                difficulty: MissionDifficultyModel(rawValue: dto.difficulty) ?? .low,
                                exp: dto.expEarned
                            )
                        }
                    }
                    .catch { err in
                        error.accept(err.localizedDescription)
                        return .just([])
                    }
            }
            .do(onNext: { _ in isMissionLoading.accept(false) })
            .bind(to: selectedDayMissions)
            .disposed(by: disposeBag)
        
        
        // 월 타이틀
        let monthTitle = currentMonth
            .map { date -> String in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "yyyy년 M월"
                return formatter.string(from: date)
            }
            .asDriver(onErrorJustReturn: "")
        
        // 데이터 로드
        let loadTrigger = Observable.merge(
            input.viewDidLoad.map { Date() },  // 초기 진입 시 현재 날짜
            input.monthChanged
        )
        
        loadTrigger
            .do(onNext: { date in
                print("date : \(date)")
                currentMonth.accept(date)  // currentMonth 업데이트
                isLoading.accept(true)
            })
            .flatMapLatest { [weak self] date -> Observable<MonthlyMissionSummary?> in
                guard let self = self else { return .empty() }
                
                let targetMonth = self.formatMonth(from: date)
                
                return self.missionService.fetchMonthlyMissions(targetMonth: targetMonth)
                    .asObservable()
                    .map { response -> MonthlyMissionSummary? in
                        // DTO → Domain Model 변환
                        guard response.success else {
                            if let errorMessage = response.errorMessage {
                                error.accept(errorMessage)
                            }
                            return nil
                        }
                        
                        return response.data.toDomain()
                    }
                    .catch { err in
                        error.accept(err.localizedDescription)
                        return .just(nil)
                    }
            }
            .do(onNext: { _ in isLoading.accept(false) })
            .bind(to: dailyMissions)
            .disposed(by: disposeBag)
        
        // 출석일 수
        let attendanceDays = dailyMissions
            .map { $0?.totalCompletedDays ?? 0 }
            .asDriver(onErrorJustReturn: 0)
        
        // 완료한 미션 총 개수
        let completedMissions = dailyMissions
            .map { $0?.totalMissionCount ?? 0 }
            .asDriver(onErrorJustReturn: 0)
        
        let dailyMissionsDriver = dailyMissions
            .map { $0?.dailyMissions ?? [] }
            .asDriver(onErrorJustReturn: [])
        
        // 성장 차트
        let growthChartTrigger = Observable.merge(
            input.viewDidLoad.map { _ in () },
            input.growthChartRefresh.asObservable()
        )
        
        growthChartTrigger
            .do(onNext: { _ in
                print("Trigger 동작")
                isLoading.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[HistoryModel.GrowthData]> in
                guard let self = self else { return .empty() }
                
                return self.missionService.fetchGrowthChart()
                    .asObservable()
                    .map { response -> [HistoryModel.GrowthData] in
                        guard response.success else {
                            if let errorMessage = response.errorMessage {
                                error.accept(errorMessage)
                            }
                            return []
                        }
                        return response.data.toDomain()
                    }
                    .catch { err in
                        error.accept(err.localizedDescription)
                        return .just([])
                    }
            }
            .bind(to: growthData)
            .disposed(by: disposeBag)
        
        return Output(
            monthTitle: monthTitle,
            attendanceDays: attendanceDays,
            completedMissions: completedMissions,
            dailyMissions: dailyMissionsDriver,
            selectedDayMissions: selectedDayMissions.asDriver(onErrorJustReturn: []),
            growthChart: growthData.asDriver(onErrorJustReturn: []),
            isLoading: isLoading.asDriver(),
            isMissionLoading: isMissionLoading.asDriver(onErrorJustReturn: false),
            error: error.asDriver(onErrorJustReturn: "")
        )
    }
    
    // MARK: - Helper
    private func formatMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper
    private func formatDate(from date: Date, day: Int) -> String {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = day
        
        guard let targetDate = calendar.date(from: components) else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: targetDate)
    }
}
