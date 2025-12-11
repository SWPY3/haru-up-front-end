//
//  SocialLoginResponse.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation


// 로그인 성공 응답
struct SocialLoginResponse: Codable {
    let success: Bool
    let message: String?
    let data: AuthData?
    
    struct AuthData: Codable {
        let accessToken: String
        let refreshToken: String?
        let memberInfo: MemberInfo?
        
        // 기존회원
        let onboardingCompleted: Bool?
        // 신규회원
        let onboardingRequired: Bool?   
    }
    
    struct MemberInfo: Codable {
        let id: String
        let name: String?
        let email: String?
        let loginType: String
    }
}
