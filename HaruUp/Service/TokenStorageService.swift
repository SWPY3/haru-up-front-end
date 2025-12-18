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
    private let onboardingCompletedMemberIdKey = "HaruUp_OnboardingCompletedMemberId"
    private let memberIdKey = "HaruUp_MemberId"
    
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
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiresAtKey)
    }
    
    
    func saveMemberId(_ id: String) {
        UserDefaults.standard.set(id, forKey: memberIdKey)
    }
    
    func getMemberId() -> String? {
        return UserDefaults.standard.string(forKey: memberIdKey)
    }
    
    
    func saveOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingCompletedKey)
        
        if completed, let memberId = getMemberId() {
            UserDefaults.standard.set(memberId, forKey: onboardingCompletedMemberIdKey)
            print("✅ 온보딩 완료 기록: memberId=\(memberId)")
        }
    }
    
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    // 다른 계정으로 로그인 시 온보딩 상태 초기화
    func clearOnboardingIfDifferentUser(currentMemberId: String) {
        let savedMemberId = UserDefaults.standard.string(forKey: onboardingCompletedMemberIdKey)
        
        if let saved = savedMemberId, saved != currentMemberId {
            print("⚠️ 다른 계정 로그인: \(saved) -> \(currentMemberId)")
            UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
            UserDefaults.standard.removeObject(forKey: onboardingCompletedMemberIdKey)
        }
    }
    
    // 온보딩 상태 완전 초기화 (로그아웃 시 호출)
    func clearOnboardingState() {
            UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
            UserDefaults.standard.removeObject(forKey: onboardingCompletedMemberIdKey)
            print("🗑️ 온보딩 상태 완전 초기화")
        }
    
    // 모든 데이터 초기화 (로그아웃 시)
        func clearAll() {
            clearTokens()
            clearOnboardingState()
            UserDefaults.standard.removeObject(forKey: memberIdKey)
            print("🗑️ 모든 저장 데이터 초기화")
        }
    
//    func resetOnboardingStatus() {
//            UserDefaults.standard.removeObject(forKey: "onboardingRequired")
//            UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
//            UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
//            UserDefaults.standard.removeObject(forKey: onboardingCompletedMemberIdKey)
//            print("🔄 온보딩 상태 리셋 (테스트용)")
//        }
    
#if DEBUG
    func printCurrentStatus() {
        print("=== Token Status ===")
        print("Access Token: \(getAccessToken() ?? "nil")")
        print("Token Valid: \(isTokenValid())")
        print("Onboarding Completed: \(isOnboardingCompleted())")
        print("===================")
    }
#endif
}
