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
        case invalidGoal
    }
    
    
    struct Input {
        let goalInput: Observable<String>
        let nextButtonTapped: Observable<Void>
        let isValidGoal: Observable<Bool>
    }
    
    struct Output {
        let isLengthValid: Driver<Bool>
        let buttonTapValidation: Driver<ValidationResult>
        let requestValidation: Driver<Void>
    }
    
    private weak var coordinator: GoalInputSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentGoalInput = BehaviorRelay<String>(value: "")
    private let validationRequestSubject = PublishSubject<Void>()
    private let isValidGoalRelay = PublishRelay<Bool>()
    
    private let curationData: CurationData
    
    init(coordinator: GoalInputSelectCoordinator, curationData: CurationData) {
        self.coordinator = coordinator
        self.curationData = curationData
    }
    
    func transform(input: Input) -> Output {
        input.goalInput
            .bind(to: currentGoalInput)
            .disposed(by: disposeBag)
        
        input.isValidGoal
            .subscribe(onNext: { [weak self] isValid in
                print("📥 [ViewModel] ViewController로부터 응답 받음: \(isValid)")
                self?.isValidGoalRelay.accept(isValid)
            })
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
            .flatMap { [weak self] goalInput -> Observable<ValidationResult> in
                guard let self = self else { return .just(.empty) }
                
                // 기본 유효성 검사 먼저 수행
                let basicValidation = self.validateGoalInputBasic(goalInput)
                
                if case .success = basicValidation {
                    // 기본 검사 통과 시, API 검사 수행
                    return self.validateWithAPI(goalInput)
                } else {
                    // 기본 검사 실패 시 바로 반환
                    return .just(basicValidation)
                }
            }
            .asDriver(onErrorJustReturn: .empty)
        
        input.nextButtonTapped
            .withLatestFrom(currentGoalInput)
            .withLatestFrom(buttonTapValidation.asObservable()) { ($0, $1) }
            .subscribe(onNext: { [weak self] (goalInput, result) in
                guard let self = self else { return }
                
                let trimmedgoalInput = goalInput.trimmingCharacters(in: .whitespaces)
                let goalInputToInterest = InterestData(id: curationData.goal!.id, name: trimmedgoalInput)
                print("🔵 다음 버튼 탭됨 - 목표: \(trimmedgoalInput)")
                print("🔍 유효성 검사 결과: \(result)")
                
                if case .success = result {
                    print("✅ 목표 입력 완료")
                    self.coordinator?.showNextFlow(selectedGoalInput: goalInputToInterest)
                } else {
                    print("❌ 유효성 검사 실패: \(result)")
                }
            })
            .disposed(by: disposeBag)
        
        
        // 유효성 검사 요청
        let requestValidation = validationRequestSubject
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            isLengthValid: isLengthValid,
            buttonTapValidation: buttonTapValidation,
            requestValidation: requestValidation
        )    }
    
    
    // MARK: - Validation Methods
    /// 전체 유효성 검사 (버튼 탭 시에만 실행)
    private func validateGoalInputBasic(_ goalInput: String) -> ValidationResult {
        
        // 1. 빈 문자열 체크
        if goalInput.isEmpty {
            return .empty
        }
        
        // 2. 길이 체크
        if goalInput.count < 2 {
            return .tooShort
        }
        
        //        if trimmed.count > 20 {
        //            return .tooLong
        //        }
        
        return .success
    }
    // API를 통한 유효성 검사 (세부 관심사와 일치 여부)
    // 현재는 임시로 true/false를 반환하도록 구현
    private func validateWithAPI(_ goalInput: String) -> Observable<ValidationResult> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(.empty)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 유효성 검사 요청 발송
            self.validationRequestSubject.onNext(())
            
            // isValidGoalRelay에서 응답을 기다림
            let disposable = self.isValidGoalRelay
                .take(1)
                .subscribe(onNext: { isValid in
                    if isValid {
                        observer.onNext(.success)
                    } else {
                        observer.onNext(.invalidGoal)
                    }
                    observer.onCompleted()
                })
            
            return disposable
        }
    }
    
    // ViewController에서 호출할 메서드 (API 응답 대신 사용)
    func setGoalValidation(_ isValid: Bool) {
        isValidGoalRelay.accept(isValid)
    }
}
