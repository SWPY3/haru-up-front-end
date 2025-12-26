//
//  NicknameSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/19/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

final class NicknameSelectViewModel {
    
    //  유효성 검사 결과 타입 정의
    enum ValidationResult {
        case success
        case empty
        case tooShort
        case tooLong
        case invalidCharacters      // 한글이 아닌 문자 포함 (숫자, 영어, 특수문자 등)
        case incompleteKorean        // 자음/모음이 섞인 경우
        case duplicated
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
        
        // 실시간: 2~10글자 체크만
        let isLengthValid = input.nicknameInput
            .map { text -> Bool in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let count = trimmed.count
                return count >= 2 && count <= 10
            }
            .asDriver(onErrorJustReturn: false)
        
        let finalValidation = input.nextButtonTapped
            .withLatestFrom(currentNickname)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .flatMapLatest { [weak self] nickname -> Observable<ValidationResult> in
                guard let self = self else { return .just(.empty) }
                
                let basic = self.validateNickname(nickname)
                guard case .success = basic else { return .just(basic) }
                
                return self.checkNicknameDuplicate(nickname)
            }
            .share(replay: 1)
    
        finalValidation
            .filter { $0 == .success }
            .withLatestFrom(currentNickname)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .subscribe(onNext: { [weak self] nick in
                self?.coordinator?.showJobSelectFlow(selectedNickname: nick)
            })
            .disposed(by: disposeBag)
        
        return Output(
            isLengthValid: isLengthValid,
            buttonTapValidation: finalValidation.asDriver(onErrorJustReturn: .empty)
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
    
    private func checkNicknameDuplicate(_ nickname: String) -> Observable<ValidationResult> {
        
        return Observable.create { observer in
            let urlString = NetworkDefine.ProfileAPI.nicknameDuplicateCheck.url
            
            
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                print("❌ refreshToken이 없습니다")
                observer.onError(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "인증 토큰이 없습니다"]))
                return Disposables.create()
            }
            
            print("📡 중복 체크 요청: \(nickname)")
            print("🌐 URL: \(urlString)")
            print("🔑 RefreshToken: \(refreshToken)")
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "jwt-token": refreshToken
            ]
            
            let requestDTO = UpdateNicknameRequest(nickName: nickname)
            
            let request = AF.request(
                urlString,
                method: .post,
                parameters: requestDTO,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("📥 API 응답 성공")
                        
                        if let json = value as? [String: Any],
                           let success = json["success"] as? Bool {
                            
                            print("✅ success = \(success)")
                            
                            if success {
                                // true = 중복 없음 (사용 가능)
                                observer.onNext(.success)
                            } else {
                                // false = 중복 있음 (사용 불가)
                                observer.onNext(.duplicated)
                            }
                        } else {
                            print("❌ JSON 파싱 실패")
                            //                            observer.onNext(.success) // 파싱 오류 시 일단 통과
                            observer.onError(NSError(domain: "ParsingError", code: -1))
                            return
                        }
                        
                        observer.onCompleted()
                        
                    case .failure(let error):
                        print("❌ API 호출 실패: \(error.localizedDescription)")
                        
                        // 네트워크 오류 시 처리
                        if let statusCode = response.response?.statusCode {
                            print("📛 HTTP Status Code: \(statusCode)")
                        }
                        
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    
}
