//
//  ForeignLanguageInputBottomSheetViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/22/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ForeignLanguageInputBottomSheetViewModel {
    
    enum ValidationResult {
        case success
        case empty
        case tooShort
        case tooLong
        case invalidCharacters      // 한글이 아닌 문자 포함 (숫자, 영어, 특수문자 등)
        case incompleteKorean        // 자음/모음이 섞인 경우
    }
    
    struct Input {
        let languageInput: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isLengthValid: Driver<Bool>
        let buttonTapValidation: Driver<ValidationResult>
    }
    
    private let currentLanguage = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        input.languageInput
            .bind(to: currentLanguage)
            .disposed(by: disposeBag)
        
        let isLengthValid = input.languageInput
            .map { text -> Bool in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let count = trimmed.count
                return count >= 2 && count <= 15
            }
            .asDriver(onErrorJustReturn: false)
        
        let buttonTapValidation = input.nextButtonTapped
            .withLatestFrom(currentLanguage)
            .map { [weak self] language -> ValidationResult in
                guard let self = self else { return .empty }
                return self.validateLanguage(language)
            }
            .asDriver(onErrorJustReturn: .empty)
        
        input.nextButtonTapped
            .withLatestFrom(currentLanguage)
            .subscribe(onNext: { [weak self] language in
                guard let self = self else { return }
                
                let trimmedLanguage = language.trimmingCharacters(in: .whitespaces)
                print("🔵 다음 버튼 탭됨 - 언어: \(trimmedLanguage)")
                
                let result = self.validateLanguage(trimmedLanguage)
                print("🔍 유효성 검사 결과: \(result)")
                
                if case .success = result {
                    print("✅ 닉네임 입력 완료")
                } else {
                    print("❌ 유효성 검사 실패: \(result)")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(isLengthValid: isLengthValid, buttonTapValidation: buttonTapValidation)
        
        //        // 텍스트 입력에 따른 검증 결과
        //        let validationResult = input.languageInput
        //            .map { [weak self] text -> (isValid: Bool, message: String?) in
        //                return self?.validateInput(text) ?? (false, nil)
        //            }
        //            .share(replay: 1)
        //
        //        // 유효성 여부
        //        let isValid = validationResult
        //            .map { $0.isValid }
        //            .asDriver(onErrorJustReturn: false)
        //
        //        // 경고 메시지
        //        let warningMessage = validationResult
        //            .map { $0.message }
        //            .asDriver(onErrorJustReturn: nil)
        //
        //        // 클리어 버튼 탭 처리
        //        let clearText = input.clearButtonTapped
        //            .asDriver(onErrorDriveWith: .empty())
        //
        //        return Output(
        //            isValid: isValid,
        //            warningMessage: warningMessage,
        //            clearText: clearText
        //        )
    }
    
    // 입력 검증 로직
    //    private func validateInput(_ text: String) -> (isValid: Bool, message: String?) {
    //        let trimmed = text.trimmingCharacters(in: .whitespaces)
    //
    //        // 1. 비어있는 경우
    //        if trimmed.isEmpty {
    //            return (false, "*외국어를 입력해주세요.")
    //        }
    //
    //        // 2. 자음/모음 섞여있는지 체크
    //        if containsIncompleteKorean(trimmed) {
    //            return (false, "*올바른 형태로 입력해주세요.")
    //        }
    //
    //        // 3. 2~15자 이내 체크
    //        if trimmed.count < 2 || trimmed.count > 15 {
    //            return (false, "*2~15자 이내로 입력해주세요.")
    //        }
    //
    //        // 모든 조건 통과
    //        return (true, nil)
    //    }
    
    // 전체 유효성 검사 (버튼 탭 시에만 실행)
    private func validateLanguage(_ language: String) -> ValidationResult {
        let trimmed = language.trimmingCharacters(in: .whitespaces)
        
        // 1. 빈 문자열 체크
        if trimmed.isEmpty {
            return .empty
        }
        
        // 2. 길이 체크
        if trimmed.count < 2 {
            return .tooShort
        }
        
        if trimmed.count > 15 {
            return .tooLong
        }
        
        // 3. 한글만 포함되어 있는지 체크
        if !isOnlyKorean(trimmed) {
            return .invalidCharacters
        }
        
        // 4. 완성된 한글인지 체크 (자음/모음 섞임 방지)
        if !isCompleteKorean(trimmed) {
            return .incompleteKorean
        }
        
        return .success
    }
    
    // 한글만 포함되어 있는지 검사 (숫자, 영어, 특수문자 제외)
    private func isOnlyKorean(_ text: String) -> Bool {
        let koreanPattern = "^[가-힣ㄱ-ㅎㅏ-ㅣ\\s]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", koreanPattern)
        return predicate.evaluate(with: text)
    }
    
    /// 완성된 한글인지 검사 (자음/모음 섞임 방지)
    private func isCompleteKorean(_ text: String) -> Bool {
        // 공백 제거
        let trimmed = text.replacingOccurrences(of: " ", with: "")
        
        for char in trimmed {
            let unicodeScalar = char.unicodeScalars.first!.value
            
            // 완성된 한글: 0xAC00(가) ~ 0xD7A3(힣)
            let isCompleteHangul = (0xAC00...0xD7A3).contains(unicodeScalar)
            
            // 초성(자음): 0x1100 ~ 0x1112
            let isChosung = (0x1100...0x1112).contains(unicodeScalar)
            
            // 중성(모음): 0x1161 ~ 0x1175
            let isJungsung = (0x1161...0x1175).contains(unicodeScalar)
            
            // 종성: 0x11A8 ~ 0x11C2
            let isJongsung = (0x11A8...0x11C2).contains(unicodeScalar)
            
            // 자음 모음: 0x3131 ~ 0x318E (ㄱ-ㅎ, ㅏ-ㅣ)
            let isJamoCompat = (0x3131...0x318E).contains(unicodeScalar)
            
            // 완성된 한글이 아니고, 자음/모음만 있으면 false
            if !isCompleteHangul && (isChosung || isJungsung || isJongsung || isJamoCompat) {
                print("❌ 미완성 문자 발견: \(char) (Unicode: \(String(format: "%X", unicodeScalar)))")
                return false
            }
            
            // 완성된 한글도 아니고 자음/모음도 아니면 (숫자, 영어 등) false
            if !isCompleteHangul && !isChosung && !isJungsung && !isJongsung && !isJamoCompat && char != " " {
                print("❌ 허용되지 않는 문자: \(char)")
                return false
            }
        }
        
        return true
    }
    
    
    // 한글 입력 체크 (자음/모음만 있는 경우)
//    private func containsIncompleteKorean(_ text: String) -> Bool {
//        for char in text {
//            let scalar = char.unicodeScalars.first?.value ?? 0
//            
//            if (0x3131...0x314E).contains(scalar) || (0x314F...0x3163).contains(scalar) {
//                return true
//            }
//        }
//        return false
//    }
}
