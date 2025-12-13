//
//  SplashViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/12/25.
//

import Foundation
import RxSwift
import RxCocoa


enum SplashResult {
    case needLogin
    case onboardingRequired
    case onboardingCompleted
}

final class SplashViewModel {
    private let tokenStorage = TokenStorageService.shared
    private let disposeBag = DisposeBag()
    private let minDisplayTime: TimeInterval = 0.8
    
    
    func checkAuthStatus() -> Observable<SplashResult> {
        let start = Date()
        
        // 로컬 토큰 검사 (동기)
        let result : SplashResult = {
            guard tokenStorage.isTokenValid() else { return .needLogin }
            return tokenStorage.isOnboardingCompleted() ? .onboardingCompleted : .onboardingRequired
        }()
        
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, minDisplayTime - elapsed)
        
        // 최소 노출시간
        return Observable.just(result)
            .delay(.milliseconds(Int(remaining * 1000)), scheduler: MainScheduler.instance)
            .take(1)
    }
}
