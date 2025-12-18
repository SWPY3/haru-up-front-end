//
//  SocialLoginResponse.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation

// 백엔드 응답 DTO
struct SocialLoginResponseDTO: Decodable {
    let success: Bool
    let data: AuthData?
    let errorMessage: String?
    
    struct AuthData: Decodable {
        let id: Int
        let name: String?
        let password: String?
        let email: String?
        let loginType: String
        let snsId: String?
        let status: String
        let accessToken: String
        let refreshToken: String
    }
}


