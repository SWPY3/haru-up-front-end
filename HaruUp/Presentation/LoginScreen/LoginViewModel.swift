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
    
    func transform(_ input: Input) -> Output {
        let errorRelay = PublishRelay<String>()
        let loginSuccessRelay = PublishRelay<SocialLoginResult>()
        
        // Kakao
        input.kakaoLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<SocialLoginResult> in
                guard let self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.authService.loginWithKakao()
                    .asObservable()
                    .do(onNext: { [weak self] _ in
                            self?.isLoadingRelay.accept(false)
                    }, onError: { [weak self] error in
                        self?.isLoadingRelay.accept(false)
                        errorRelay.accept(error.localizedDescription)
                    })
                    .catch { error in
                        return .just(SocialLoginResult(success: false, onboardingCompleted: false))
                    }
            }
            .filter { $0.success }              // true인 경우(성공)만 통과
            .bind(to: loginSuccessRelay) // 성공 시에만 loginSuccess = true
            .disposed(by: disposeBag)
        
        // Apple
        input.appleLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<SocialLoginResult> in
                guard let self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.authService.loginWithApple()
                    .asObservable()
                    .do(onNext: { [weak self] _ in
                        self?.isLoadingRelay.accept(false)
                    }, onError: { [weak self] error in
                        self?.isLoadingRelay.accept(false)
                        errorRelay.accept(error.localizedDescription)
                    })
                    .catch { error in
                        return .just(SocialLoginResult(success: false, onboardingCompleted: false))
                    }
            }
            .filter { $0.success }              // true인 경우(성공)만 통과
            .bind(to: loginSuccessRelay) // 성공 시에만 loginSuccess = true
            .disposed(by: disposeBag)
        
        // Naver
        input.naverLoginTapped
                    .flatMapLatest { [weak self] _ -> Observable<SocialLoginResult> in
                        guard let self = self else { return .empty() }
                        
                        self.isLoadingRelay.accept(true)
                        
                        return self.authService.loginWithNaver()
                            .asObservable()
                            .do(onNext: { [weak self] _ in
                                self?.isLoadingRelay.accept(false)
                            }, onError: { [weak self] error in
                                self?.isLoadingRelay.accept(false)
                                errorRelay.accept(error.localizedDescription)
                            })
                            .catch { error in
                                return .just(SocialLoginResult(success: false, onboardingCompleted: false))
                            }
                    }
                    // false는 성공으로 보지 않도록 필터링
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
