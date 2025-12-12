//
//  SocialLoginRequest.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation


enum SocialLoginProvider: String, Codable {
    case kakao = "KAKAO"
    case apple = "APPLE"
    case naver = "NAVER"
}

struct SocialLoginRequest {
    let provider: SocialLoginProvider
    let accessToken: String
    let snsUserId: String   
    let email: String?
    let name: String?
    
    // Apple 로그인 전용
    let identityToken: String?
    let authorizationCode: String?
    let userIdentifier: String?
    let nonce: String?
    
    init(
        provider: SocialLoginProvider,
        accessToken: String,
        snsUserId: String,
        email: String? = nil,
        name: String? = nil,
        identityToken: String? = nil,
        authorizationCode: String? = nil,
        userIdentifier: String? = nil,
        nonce: String? = nil
    ) {
        self.provider = provider
        self.accessToken = accessToken
        self.snsUserId = snsUserId
        self.email = email
        self.name = name
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.userIdentifier = userIdentifier
        self.nonce = nonce
    }
}
