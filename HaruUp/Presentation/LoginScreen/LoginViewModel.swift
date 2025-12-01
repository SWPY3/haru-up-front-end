//
//  LoginViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/1/25.
//

import RxSwift
import RxCocoa

// TODO: 서버단에서 보내주는 에러 메시지에 따라 구분
enum LoginError: Error {
    
}

final class LoginViewModel {
    
    struct Input {
        let kakaoLoginTapped: Observable<Void>
        let appleLoginTapped: Observable<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
        let loginSuccess: Signal<Bool>
    }
    
    private let disposeBag = DisposeBag()
    private let authService: AuthService
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false) // 서버 통신 로딩중
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func transform(_ input: Input) -> Output {
        let errorRelay = PublishRelay<String>()
        let loginSuccessRelay = PublishRelay<Bool>()
        
        // Kakao
        input.kakaoLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.authService.loginWithKakao()
                    .asObservable()
                    .do(onNext: { [weak self] success in
                            self?.isLoadingRelay.accept(false)
                            if !success {
                                // TODO: 에러 메시지 정의
                                errorRelay.accept("카카오 로그인에 실패했습니다.")
                            }
                        })
            }
            .filter { $0 }              // true인 경우(성공)만 통과
            .bind(to: loginSuccessRelay) // 성공 시에만 loginSuccess = true
            .disposed(by: disposeBag)
        
        // Apple
        input.appleLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                
                self.isLoadingRelay.accept(true)
                
                return self.authService.loginWithApple()
                    .asObservable()
                    .do(onNext: { [weak self] success in
                            self?.isLoadingRelay.accept(false)
                            if !success {
                                errorRelay.accept("애플 로그인에 실패했습니다.")
                            }
                        })
            }
            .filter { $0 }              // true인 경우(성공)만 통과
            .bind(to: loginSuccessRelay) // 성공 시에만 loginSuccess = true
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal(),
            loginSuccess: loginSuccessRelay.asSignal()
        )
    }
}
