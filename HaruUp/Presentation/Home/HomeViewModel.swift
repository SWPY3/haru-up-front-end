//
//  HomeViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import RxSwift

final class HomeViewModel {

    struct Input {
        let viewDidAppear: Observable<Void>
    }
    
    struct Output {
        let showTodayMissionFlow: Observable<Void>
    }
    
    private let missionService: MissionServiceProtocol
    
    init(missionService: MissionServiceProtocol) {
        self.missionService = missionService
    }
    
    func transform(input: Input) -> Output {
        let showTodayMissionFlow = input.viewDidAppear
            .take(1)
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                return self.missionService.needShowTodayMissionFlow().asObservable()
            }
            .filter { print("$0: \($0)")
                return $0 }
            .map { _ in () } // Void로 변환하기위해 사용
        
        return Output(showTodayMissionFlow: showTodayMissionFlow)
    }
}
