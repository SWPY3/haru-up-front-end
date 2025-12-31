//
//  BirthSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa


final class BirthSelectViewModel {
    
    struct Input {
        let birthInput: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let isLengthValid: Driver<Bool>
        let buttonTapValidation: Driver<BirthValidationResult>
    }
    
    private weak var coordinator: BirthSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentBirth = BehaviorRelay<String>(value: "")

    
    init(coordinator: BirthSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        // 생년월일 입력 처리
        input.birthInput
            .bind(to: currentBirth)
            .disposed(by: disposeBag)
        
//        let isLengthValid = input.birthInput
//            .map { text -> Bool in
//                let trimmed = text.trimmingCharacters(in: .whitespaces)
//                let count = trimmed.count
//                return count == 8
//            }
//            .asDriver(onErrorJustReturn: false)
        
        // 8자리 글자 검사
        let isLengthValid  = input.birthInput
            .map { text -> Bool in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let count = trimmed.count
                return count == 8
            }
            .asDriver(onErrorJustReturn: false)
        
        
        // 버튼 탭 시: 전체 유효성 검사
        let buttonTapValidation = input.nextButtonTapped
            .withLatestFrom(currentBirth)
            .map { [weak self] birth -> BirthValidationResult in
                guard let self = self else { return .empty }
                return self.validateBirth(birth)
            }
            .asDriver(onErrorJustReturn: .empty)
        
        
        // 유효성 검사 통과 시 화면 전환
        input.nextButtonTapped
            .withLatestFrom(currentBirth)
            .subscribe(onNext: { [weak self] birth in
                guard let self = self else { return }
                
                let trimmedBirth = birth.trimmingCharacters(in: .whitespaces)
                print("🔵 다음 버튼 탭됨 - 생년월일: \(birth)")
                let result = self.validateBirth(trimmedBirth)
                
                if case .success = result {
                    self.coordinator?.showInterestSelectFlow(selectedBirth: trimmedBirth)
                } else {
                    print("❌ 유효성 검사 실패: \(result)")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(isLengthValid: isLengthValid,
                      buttonTapValidation: buttonTapValidation)
        
    }
    
    private func validateBirth(_ birth: String) -> BirthValidationResult {
        let trimmed = birth.trimmingCharacters(in: .whitespaces)
        
        if trimmed.isEmpty {
            return .empty
        }
        
        if trimmed.count < 8 {
            return .tooShort
        }
        
        if trimmed.count > 8 {
            return .tooLong
        }
        
        if !isValidDate(trimmed) {
            return .invalid
        }
        
        return .success
    }
    
    // 생년월일 유효성 검사 (실제 날짜인지 확인)
    private func isValidDate(_ birth: String) -> Bool {
        guard birth.count == 8 else { return false }
        let yearString = String(birth.prefix(4))
        let monthString = String(birth.dropFirst(4).prefix(2))
        let dayString = String(birth.dropFirst(6).prefix(2))
        
        guard let year = Int(yearString),
              let month = Int(monthString),
              let day = Int(dayString) else {
            return false }
        
        // 연도 범위 체크 (1900년 ~ 현재년도)
        let currentYear = Calendar.current.component(.year, from: Date())
        guard year >= 1900 && year <= currentYear else { return false }
        
        // 월 범위 체크
        guard month >= 1 && month <= 12 else { return false }
        
        // 일 범위 체크
        guard day >= 1 && day <= 31 else { return false }
        
        // 실제 날짜 유효성 체크
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: birth) != nil
    }
}
