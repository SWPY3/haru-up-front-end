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
        let daySelected: Observable<Int>
    }
    
    // MARK: - Output
    struct Output {
        let monthTitle: Driver<String>
        let attendanceDays: Driver<Int>
        let completedMissions: Driver<Int>
        let dailyMissions: Driver<[DailyMission]>
        let selectedDayMissions: Driver<Int>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }
    
    // MARK: - Properties
    private let historyService: HistoryServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(historyService: HistoryServiceProtocol = HistoryService()) {
        self.historyService = historyService
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)
        let error = PublishRelay<String>()
        let dailyMissions = BehaviorRelay<[DailyMission]>(value: [])
        let currentMonth = BehaviorRelay<Date>(value: Date())
        let selectedDay = BehaviorRelay<Int>(value: Calendar.current.component(.day, from: Date()))
        
        // 현재 월 업데이트
        input.monthChanged
            .bind(to: currentMonth)
            .disposed(by: disposeBag)
        
        // 선택된 날짜 업데이트
        input.daySelected
            .bind(to: selectedDay)
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
            input.viewDidLoad,
            input.monthChanged.map { _ in () }
        )
        
        loadTrigger
            .withLatestFrom(currentMonth)
            .do(onNext: { _ in isLoading.accept(true) })
            .flatMapLatest { [weak self] date -> Observable<[DailyMission]> in
                guard let self = self else { return .empty() }
                
                let targetMonth = self.formatMonth(from: date)
                
                return self.historyService.fetchMonthlyMissions(targetMonth: targetMonth)
                    .asObservable()
                    .map { response -> [DailyMission] in
                        // DTO → Domain Model 변환
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
            .do(onNext: { _ in isLoading.accept(false) })
            .bind(to: dailyMissions)
            .disposed(by: disposeBag)
        
        // 출석일 수
        let attendanceDays = dailyMissions
            .map { missions in
                missions.filter { $0.hasCompleted }.count
            }
            .asDriver(onErrorJustReturn: 0)
        
        // 완료한 미션 총 개수
        let completedMissions = dailyMissions
            .map { missions in
                missions.reduce(0) { $0 + $1.completedCount }
            }
            .asDriver(onErrorJustReturn: 0)
        
        // 선택된 날짜의 미션 수
        let selectedDayMissions = Observable
            .combineLatest(dailyMissions, selectedDay)
            .map { missions, day -> Int in
                missions.first { $0.day == day }?.completedCount ?? 0
            }
            .asDriver(onErrorJustReturn: 0)
        
        return Output(
            monthTitle: monthTitle,
            attendanceDays: attendanceDays,
            completedMissions: completedMissions,
            dailyMissions: dailyMissions.asDriver(onErrorJustReturn: []),
            selectedDayMissions: selectedDayMissions,
            isLoading: isLoading.asDriver(),
            error: error.asDriver(onErrorJustReturn: "")
        )
    }
    
    // MARK: - Helper
    private func formatMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
