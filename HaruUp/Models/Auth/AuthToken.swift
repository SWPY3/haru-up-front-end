//
//  AuthToken.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation


struct AuthToken {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date?
    
    init(accessToken: String, refreshToken: String? = nil, expiresAt: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}
