//
//  TokenStorageService.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation


final class TokenStorageService {
    static let shared = TokenStorageService()
    
    private let accessTokenKey = "HaruUp_AccessToken"
    private let refreshTokenKey = "HaruUp_RefreshToken"
    private let tokenExpiresAtKey = "HaruUp_TokenExpiresAt"
    private let onboardingCompletedKey = "HaruUp_OnboardingCompleted"
    
    private init() {}
    
    func saveToken(_ token: AuthToken) {
        UserDefaults.standard.set(token.accessToken, forKey: accessTokenKey)
        if let refreshToken = token.refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        }
        if let expiresAt = token.expiresAt {
            UserDefaults.standard.set(expiresAt, forKey: tokenExpiresAtKey)
        }
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    func isTokenValid() -> Bool {
        guard let accessToken = getAccessToken(), !accessToken.isEmpty else {
            return false
        }
        
        if let expiresAt = UserDefaults.standard.object(forKey: tokenExpiresAtKey) as? Date {
            return expiresAt > Date()
        }
        
        return true
    }
    
    func saveOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingCompletedKey)
    }
    
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiresAtKey)
    }
}
