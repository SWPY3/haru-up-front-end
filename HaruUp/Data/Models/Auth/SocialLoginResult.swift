//
//  SocialLoginResult.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation


struct SocialLoginResult {
    let success: Bool
    // 온보딩 완료 여부
    let onboardingCompleted: Bool
    
    init(success: Bool, onboardingCompleted: Bool) {
        self.success = success
        self.onboardingCompleted = onboardingCompleted
    }
}
