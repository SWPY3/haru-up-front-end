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
    private let minDisplayTime: TimeInterval = 0.5
    
    
    func checkAuthStatus() -> Observable<SplashResult> {
        let start = Date()
        
        
#if DEBUG
        print("=== Splash 상태 확인 ===")
        print("토큰 유효: \(tokenStorage.isTokenValid())")
        print("온보딩 완료: \(tokenStorage.isOnboardingCompleted())")
        print("Access Token: \(tokenStorage.getAccessToken() ?? "없음")")
#endif
        
        // 로컬 토큰 검사 (동기)
        let result : SplashResult = {
            guard tokenStorage.isTokenValid() else { return .needLogin }
            
            let onboardingDone = tokenStorage.isOnboardingCompleted()
            if onboardingDone {
                print("-> 결과: onboardingCompleted")
                return .onboardingCompleted
            } else {
                print("-> 결과: onboardingRequired") 
                return .onboardingRequired
            }
        }()
        
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, minDisplayTime - elapsed)
        
        // 최소 노출시간
        return Observable.just(result)
            .delay(.milliseconds(Int(remaining * 1000)), scheduler: MainScheduler.instance)
    }
}
