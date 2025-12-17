//
//  SocialLoginResult.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation


struct SocialLoginResult {
    let success: Bool
    // 기존 회원의 온보딩 완료 여부
    let onboardingCompleted: Bool?
    // 신규 회원의 온보딩 완료 여부
    let onboardingRequired: Bool?
    
    init(success: Bool, onboardingCompleted: Bool? = nil, onboardingRequired: Bool? = nil) {
        self.success = success
        self.onboardingCompleted = onboardingCompleted
        self.onboardingRequired = onboardingRequired
    }
}
