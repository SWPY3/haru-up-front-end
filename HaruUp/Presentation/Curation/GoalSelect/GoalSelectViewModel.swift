//
//  GoalSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa


final class GoalSelectViewModel {
    struct Input {
        let goalSelected: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let goals: Driver<[String]>
        let selectedGoal: Driver<String?>
    }
    
    private weak var coordinator: GoalSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedInterestDetail: String
    
    private let currentSelectedGoal = BehaviorRelay<String?>(value: nil)
    
    init(coordinator: GoalSelectCoordinator?, selectedInterestDetail: String) {
        self.coordinator = coordinator
        self.selectedInterestDetail = selectedInterestDetail
    }
    
    private let goallList: [String] = [
        "시험준비",
        "회화공부",
        "문법공부",
        "단어공부",
        "직접 입력할게요"
    ]
    
    func transform(input: Input) -> Output {
        input.goalSelected
            .bind(to: currentSelectedGoal)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .withLatestFrom(currentSelectedGoal)
            .subscribe(onNext: { [weak self] selectedGoal in
                guard let selectedGoal = selectedGoal else {
                    print("목표를 선택해주세요")
                    return
                }
                
                if selectedGoal == "직접 입력할게요" {
                    self?.coordinator?.showGoalInputFlow(selectedGoal: selectedGoal)
                } else {
                    
                    self?.coordinator?.showNextFlow(selectedGoal: selectedGoal)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            goals: Driver.just(goallList),
            selectedGoal: currentSelectedGoal.asDriver()
        )
    }
    
}
