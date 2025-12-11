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
    
    func transform(input: Input) -> Output {
        let showTodayMissionFlow = input.viewDidAppear
            .filter { _ in true }
            .map { _ in () } // Void로 변환하기위해 사용
        
        return Output(showTodayMissionFlow: showTodayMissionFlow)
    }
}
