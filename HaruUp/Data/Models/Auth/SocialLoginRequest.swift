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

struct SocialLoginRequestDTO: Encodable {
    let loginType: String
    let snsId: String
    let email: String
    let name: String
    
    
    // Apple 전용 (서버가 요구하는 경우에만)
    let identityToken: String?
    let authorizationCode: String?
    let nonce: String?
    
    enum CodingKeys: String, CodingKey {
        case loginType
        case snsId
        case email
        case name
        case identityToken
        case authorizationCode
        case nonce
    }
    // 카카오/네이버용 초기화
    init(
        loginType: String,
        snsId: String,
        email: String,
        name: String
    ) {
        self.loginType = loginType
        self.snsId = snsId
        self.email = email
        self.name = name
        self.identityToken = nil
        self.authorizationCode = nil
        self.nonce = nil
    }
    
    // Apple용 초기화
    init(
        loginType: String,
        snsId: String,
        email: String,
        name: String,
        identityToken: String?,
        authorizationCode: String?,
        nonce: String?
    ) {
        self.loginType = loginType
        self.snsId = snsId
        self.email = email
        self.name = name
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.nonce = nonce
    }
}



