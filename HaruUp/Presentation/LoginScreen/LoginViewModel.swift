//
//  LoginViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/1/25.
//

import RxSwift
import RxCocoa

import Foundation

// TODO: 서버단에서 보내주는 에러 메시지에 따라 구분
enum LoginError: Error {
    // naver
    case invalidProfile
}

final class LoginViewModel {
    
    struct Input {
        let kakaoLoginTapped: Observable<Void>
        let appleLoginTapped: Observable<Void>
        let naverLoginTapped: Observable<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
        let loginSuccess: Signal<SocialLoginResult>
    }
    
    private let disposeBag = DisposeBag()
    private let authService: AuthService
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false) // 서버 통신 로딩중
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // 공통 로그인 처리 로직
    // 로그인 시도 -> 성공 시 CurationData 확인 -> 없으면 데이터 복구(프로필/관심사) -> 최종 결과 반환
    private func handleLogin(_ loginSingle: Single<SocialLoginResult>) -> Observable<SocialLoginResult> {
        return loginSingle
            .asObservable()
            .flatMap { [weak self] loginResult -> Observable<SocialLoginResult> in
                guard let self = self, loginResult.success else {
                    // 로그인 자체가 실패하면 그대로 반환
                    return .just(loginResult)
                }
                
                print("🔄 로그인 성공 -> 서버 데이터(프로필/관심사) 확인 시도")
                
                // 서버 데이터 조회 (프로필 + 관심사)
                return self.authService.fetchProfileAndInterests()
                    .asObservable()
                    .map { _ in
                        // 성공: 서버에 데이터가 있음 (기존 회원)
                        print("✅ 기존 회원 확인: 온보딩 건너뛰기 설정")
                        
                        // 1. 로컬에 온보딩 완료 상태 저장
                        TokenStorageService.shared.saveOnboardingCompleted(true)
                        
                        // 2. 결과 객체의 onboardingCompleted를 true로 변경하여 반환
                        return SocialLoginResult(success: true, onboardingCompleted: true)
                    }
                    .catch { error in
                        // 실패: 서버에 데이터가 없음 (신규 회원) or 네트워크 오류
                        // (보통 404나 데이터 없음 에러가 뜸)
                        print("⚠️ 신규 회원 또는 데이터 없음 (\(error)) -> 온보딩 진행 필요")
                        
                        // 1. 로컬 온보딩 미완료 상태 확실하게 저장
                        TokenStorageService.shared.saveOnboardingCompleted(false)
                        
                        // 2. 결과 객체의 onboardingCompleted를 false로 반환 -> 온보딩 화면으로 이동
                        return .just(SocialLoginResult(success: true, onboardingCompleted: false))
                    }
            }
            .flatMap { [weak self] loginResult -> Observable<SocialLoginResult> in
                // FCM 토큰 서버에 전송
                guard let self = self, loginResult.success else {
                    return .just(loginResult)
                }
                
                print("📡 FCM 토큰 서버 전송 시작")
                
                return PushNotificationService.shared.sendTokenToServerIfLoggedIn()
                    .map { _ in
                        print("✅ FCM 토큰 서버 전송 완료")
                        
                        // 성공 시 현재 토큰을 저장
                        if let token = PushNotificationService.shared.getCurrentToken() {
                            UserDefaults.standard.set(token, forKey: "fcmTokenSentToServer")
                        }
                        
                        return loginResult
                    }
                    .catch { error in
                        // FCM 토큰 전송 실패해도 로그인은 계속 진행
                        print("⚠️ FCM 토큰 서버 전송 실패: \(error)")
                        return .just(loginResult)
                    }
            }
            .do(onNext: { [weak self] _ in
                self?.isLoadingRelay.accept(false)
            }, onError: { [weak self] _ in
                self?.isLoadingRelay.accept(false)
            })
    }
    
    func transform(_ input: Input) -> Output {
        let errorRelay = PublishRelay<String>()
        let loginSuccessRelay = PublishRelay<SocialLoginResult>()
        
        // Kakao
        input.kakaoLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<SocialLoginResult> in
                guard let self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.handleLogin(self.authService.loginWithKakao())
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .filter { $0.success }
            .bind(to: loginSuccessRelay)
            .disposed(by: disposeBag)
        
        // Apple
        input.appleLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<SocialLoginResult> in
                guard let self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.handleLogin(self.authService.loginWithApple())
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .filter { $0.success }
            .bind(to: loginSuccessRelay)
            .disposed(by: disposeBag)
        
        // Naver
        input.naverLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<SocialLoginResult> in
                guard let self = self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.handleLogin(self.authService.loginWithNaver())
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .filter { $0.success }
            .bind(to: loginSuccessRelay)
            .disposed(by: disposeBag)
        

        return Output(
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal(),
            loginSuccess: loginSuccessRelay.asSignal()
        )
    }
}
