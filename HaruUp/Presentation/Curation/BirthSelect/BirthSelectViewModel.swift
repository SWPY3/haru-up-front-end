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
        let isValid: Driver<Bool>
        let formattedBirth: Driver<String>
        let showInvalidDateAlert: Driver<Void>
    }
    
    private weak var coordinator: BirthSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentBirth = BehaviorRelay<String>(value: "")
    private let invalidDateAlert = PublishSubject<Void>()
    
    init(coordinator: BirthSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        // 생년월일 입력 처리
        input.birthInput
            .bind(to: currentBirth)
            .disposed(by: disposeBag)
        
        // 다음버튼 처리
        input.nextButtonTapped
            .withLatestFrom(currentBirth)
            .subscribe(onNext: { [weak self] birth in
                print("🔵 다음 버튼 탭됨 - 생년월일: \(birth)")
                
                
                // 실제 날짜인지 검증
                if ((self?.isValidDate(birth)) != nil) {
                    print("✅ 유효한 날짜입니다")
                    self?.coordinator?.showInterestSelectFlow(selectedBirth: birth)
                } else {
                    print("❌ 유효하지 않은 날짜입니다")
                    self?.invalidDateAlert.onNext(())  // 에러 알림
                }
            })
            .disposed(by: disposeBag)
        
        // 8자리 숫자 검사
        let isValid = input.birthInput
            .map { [weak self] birth in
                guard let self = self else { return false }
                
                // 8자리이면서 실제 유효한 날짜인지 체크
                return birth.count == 8 &&
                birth.allSatisfy { $0.isNumber } &&
                self.isValidDate(birth)
            }
            .asDriver(onErrorJustReturn: false)
        
        let formattedBirth = input.birthInput
            .map { birth in
                let numbers = birth.filter { $0.isNumber }
                return String(numbers.prefix(8))
            }
            .asDriver(onErrorJustReturn: "")
        
        return Output (isValid: isValid,
                       formattedBirth: formattedBirth,
                       showInvalidDateAlert: invalidDateAlert.asDriver(onErrorJustReturn: ())
                       )
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
