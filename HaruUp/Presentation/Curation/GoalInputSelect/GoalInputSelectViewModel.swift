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
    
    enum ValidationResult {
        case success
        case empty
        case tooShort
        case tooLong
        case invalidGoal
    }
    
    
    struct Input {
        let goalInput: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isLengthValid: Driver<Bool>
        let buttonTapValidation: Driver<ValidationResult>
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
        
        let isLengthValid = input.goalInput
            .map { text -> Bool in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let count = trimmed.count
                return count >= 2 && count <= 20
            }
            .asDriver(onErrorJustReturn: false)
        
        let buttonTapValidation = input.nextButtonTapped
            .withLatestFrom(currentGoalInput)
            .map { [weak self] goalInput -> ValidationResult in
                guard let self = self else { return .empty }
                return self.validateGoalInput(goalInput)
            }
            .asDriver(onErrorJustReturn: .empty)
        
        input.nextButtonTapped
            .withLatestFrom(currentGoalInput)
            .subscribe(onNext: { [weak self] goalInput in
                guard let self = self else { return }
                
                let trimmedgoalInput = goalInput.trimmingCharacters(in: .whitespaces)
                print("🔵 다음 버튼 탭됨 - 목표: \(trimmedgoalInput)")
                
                let result = self.validateGoalInput(trimmedgoalInput)
                print("🔍 유효성 검사 결과: \(result)")
                
                if case .success = result {
                    print("✅ 목표 입력 완료")
                    self.coordinator?.showNextFlow(selectedGoalInput: trimmedgoalInput)
                } else {
                    print("❌ 유효성 검사 실패: \(result)")
                }
            })
            .disposed(by: disposeBag)
        
        
        return Output(
            isLengthValid: isLengthValid,
            buttonTapValidation: buttonTapValidation
        )
    }
    
    
    // MARK: - Validation Methods
    /// 전체 유효성 검사 (버튼 탭 시에만 실행)
    private func validateGoalInput(_ goalInput: String) -> ValidationResult {
        let trimmed = goalInput.trimmingCharacters(in: .whitespaces)
        
        // 1. 빈 문자열 체크
        if trimmed.isEmpty {
            return .empty
        }
        
        // 2. 길이 체크
        if trimmed.count < 2 {
            return .tooShort
        }
        
        if trimmed.count > 10 {
            return .tooLong
        }
        
        // 3. 세부 관심사와 맞는 목표인지 체크
        if !isCorrectWithInterestDetail(goalInput) {
            return .invalidGoal
        }
        
        return .success
    }
    
    private func isCorrectWithInterestDetail(_ text: String) -> Bool {
        let koreanPattern = "^[가-힣ㄱ-ㅎㅏ-ㅣ\\s]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", koreanPattern)
        return predicate.evaluate(with: text)
    }
}
