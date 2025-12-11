//
//  TodayMissionListViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import RxSwift

final class TodayMissionListViewModel {
    struct Input {
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let missionCompleted: Observable<Void>
    }
    
    private let missionService: MissionServiceProtocol
    
    init(missionService: MissionServiceProtocol) {
        self.missionService = missionService
    }
    
    func transform(input: Input) -> Output {
        let missionCompleted = input.completeTap
            .do(onNext: { [weak self] in
                self?.missionService.markTodayMissionSelected()
            })
            .map { _ in () }
        
        return Output(missionCompleted: missionCompleted)
    }
}
