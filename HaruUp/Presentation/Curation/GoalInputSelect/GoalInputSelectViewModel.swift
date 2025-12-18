//
//  GoalInputViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class GoalInputSelectViewModel {
    struct Input {
        let goalInput: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isValid: Driver<Bool>
        let formattedGoal: Driver<String>
        let selectedGoalInput: Driver<String>
    }
    
    private weak var coordinator: GoalInputSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentGoalInput = BehaviorRelay<String>(value: "")
    
    init(coordinator: GoalInputSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        input.goalInput
            .bind(to: currentGoalInput)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentGoalInput)
            .subscribe(onNext: { [weak self] goal in
                print("🔵 다음 버튼 탭됨 - 목표: \(goal)")
                self?.coordinator?.showNextFlow(selectedGoalInput: goal)
            })
            .disposed(by: disposeBag)
        
        let isValid = input.goalInput
            .map { goal in
                let trimmed = goal.trimmingCharacters(in: .whitespaces)
                return trimmed.count >= 2 && trimmed.count <= 15
            }
            .asDriver(onErrorJustReturn: false)
        
        // 15자 제한
        let formattedGoal = input.goalInput
            .map { goal in
                return String(goal.prefix(15))
            }
            .asDriver(onErrorJustReturn: "")
        
        return Output(
            isValid: isValid,
            formattedGoal: formattedGoal,
            selectedGoalInput: currentGoalInput.asDriver()
        )
    }
}
