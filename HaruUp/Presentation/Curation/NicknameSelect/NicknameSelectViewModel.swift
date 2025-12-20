//
//  NicknameSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/19/25.
//

import UIKit
import RxSwift
import RxCocoa


final class NicknameSelectViewModel {
    
    // ⭐ 유효성 검사 결과 타입 정의
    enum ValidationResult {
        case success
        case empty
        case tooShort
        case tooLong
        case invalidCharacters      // 한글이 아닌 문자 포함 (숫자, 영어, 특수문자 등)
        case incompleteKorean        // 자음/모음이 섞인 경우
    }
    
    struct Input {
        let nicknameInput: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isLengthValid: Driver<Bool>
        let buttonTapValidation: Driver<ValidationResult>
    }
    
    private weak var coordinator: NicknameSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentNickname = BehaviorRelay<String>(value: "")
    
    init(coordinator: NicknameSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        input.nicknameInput
            .bind(to: currentNickname)
            .disposed(by: disposeBag)
        
        // ⭐ 실시간: 2~10글자 체크만
        let isLengthValid = input.nicknameInput
            .map { text -> Bool in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let count = trimmed.count
                return count >= 2 && count <= 10
            }
            .asDriver(onErrorJustReturn: false)
        
        // ⭐ 버튼 탭 시: 전체 유효성 검사
        let buttonTapValidation = input.nextButtonTapped
            .withLatestFrom(currentNickname)
            .map { [weak self] nickname -> ValidationResult in
                guard let self = self else { return .empty }
                return self.validateNickname(nickname)
            }
            .asDriver(onErrorJustReturn: .empty)
        
        // ⭐ 유효성 검사 통과 시 화면 전환
        input.nextButtonTapped
            .withLatestFrom(currentNickname)
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                let trimmedNickname = nickname.trimmingCharacters(in: .whitespaces)
                print("🔵 다음 버튼 탭됨 - 닉네임: \(trimmedNickname)")
                
                let result = self.validateNickname(trimmedNickname)
                print("🔍 유효성 검사 결과: \(result)")
                
                if case .success = result {
                    print("✅ 닉네임 입력 완료")
                    self.coordinator?.showJobSelectFlow(selectedNickname: trimmedNickname)
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
    private func validateNickname(_ nickname: String) -> ValidationResult {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        
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
    
    /// 한글만 포함되어 있는지 검사 (숫자, 영어, 특수문자 제외)
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
}


//final class NicknameSelectViewModel {
//
//    struct Input {
//        let nicknameInput: Observable<String>
//        let nextButtonTapped: Observable<Void>
//    }
//
//    struct Output {
//        let isValid: Driver<Bool>
//        let formattedNickname: Driver<String>
//    }
//
//    private weak var coordinator: NicknameSelectCoordinator?
//    private let disposeBag = DisposeBag()
//
//    private let currentNickname = BehaviorRelay<String>(value: "")
//    private let maxLength = 10  // 닉네임 최대 길이
//
//    init(coordinator: NicknameSelectCoordinator) {
//        self.coordinator = coordinator
//    }
//
//    func transform(input: Input) -> Output {
//        input.nicknameInput
//            .bind(to: currentNickname)
//            .disposed(by: disposeBag)
//
//        input.nextButtonTapped
//            .withLatestFrom(currentNickname)
//            .subscribe(onNext: { [weak self] nickname in
//                guard let self = self else { return }
//
//                let trimmedNickname = nickname.trimmingCharacters(in: .whitespaces)
//                print("🔵 다음 버튼 탭됨 - 닉네임: \(trimmedNickname)")
//
//
//                if trimmedNickname.count >= 2 && trimmedNickname.count <= 10 {
//                    print("✅ 닉네임 입력 완료")
//                    self.coordinator?.showJobSelectFlow(selectedNickname: trimmedNickname)
//                }
//            })
//            .disposed(by: disposeBag)
//
//        let isValid = input.nicknameInput
//            .map { nickname in
//                let trimmed = nickname.trimmingCharacters(in: .whitespaces)
//                return trimmed.count >= 2 && trimmed.count <= 10
//            }
//            .asDriver(onErrorJustReturn: false)
//
//        // 닉네임 포맷팅 (최대 길이 제한)
//        let formattedNickname = input.nicknameInput
//            .map { [weak self] nickname -> String in
//                guard let self = self else { return nickname }
//                return String(nickname.prefix(self.maxLength))
//            }
//            .asDriver(onErrorJustReturn: "")
//
//        return Output(
//            isValid: isValid,
//            formattedNickname: formattedNickname
//        )
//    }
//}
