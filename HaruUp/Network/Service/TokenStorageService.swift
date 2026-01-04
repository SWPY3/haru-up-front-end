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
    private let curationDataKey = "HaruUp_CurationData"
    
    private let memberInterestsKey = "HaruUp_MemberInterests"
    private let userNicknameKey = "HaruUp_UserNickname"
    private let userProfileImgIdKey = "HaruUp_UserProfileImgId"
    
    // Apple 로그인 관련 키들
    private let appleUserIdKey = "HaruUp_AppleUserId"
    private let appleEmailKey = "HaruUp_AppleEmail"
    private let appleFullNameKey = "HaruUp_AppleFullName"
    
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
    
    // MARK: - Apple Login
    func saveAppleUserInfo(userId: String, email: String?, fullName: String?) {
        UserDefaults.standard.set(userId, forKey: appleUserIdKey)
        UserDefaults.standard.set(email, forKey: appleEmailKey)
        UserDefaults.standard.set(fullName, forKey: appleFullNameKey)
    }
    
    func getAppleUserId() -> String? {
        return UserDefaults.standard.string(forKey: appleUserIdKey)
    }
    
    func getAppleEmail() -> String? {
        return UserDefaults.standard.string(forKey: appleEmailKey)
    }
    
    func getAppleFullName() -> String? {
        return UserDefaults.standard.string(forKey: appleFullNameKey)
    }
    
    private func clearAppleLoginInfo() {
        UserDefaults.standard.removeObject(forKey: appleUserIdKey)
        UserDefaults.standard.removeObject(forKey: appleEmailKey)
        UserDefaults.standard.removeObject(forKey: appleFullNameKey)
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
    
    func saveCurationData(_ data: CurationData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: curationDataKey)
            print("✅ 큐레이션 데이터 로컬 저장 완료")
        } catch {
            print("❌ 큐레이션 데이터 저장 실패: \(error)")
        }
    }
    
    func getCurationData() -> CurationData? {
        guard let data = UserDefaults.standard.data(forKey: curationDataKey) else { return nil }
        do {
            return try JSONDecoder().decode(CurationData.self, from: data)
        } catch {
            print("❌ 큐레이션 데이터 디코딩 실패: \(error)")
            return nil
        }
    }
    
    // 온보딩 상태 완전 초기화
    func clearOnboardingState() {
        UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
        UserDefaults.standard.removeObject(forKey: onboardingCompletedMemberIdKey)
        print("🗑️ 온보딩 상태 완전 초기화")
    }
    
    func saveProfile(nickname: String, imgId: Int?) {
        UserDefaults.standard.set(nickname, forKey: userNicknameKey)
        if let imgId = imgId {
            UserDefaults.standard.set(imgId, forKey: userProfileImgIdKey)
        }
        print("✅ 프로필 정보(닉네임/이미지ID) 로컬 저장 완료")
    }
    
    func getProfile() -> (nickname: String?, imgId: Int) {
        let nickname = UserDefaults.standard.string(forKey: userNicknameKey)
        let imgId = UserDefaults.standard.integer(forKey: userProfileImgIdKey)
        return (nickname, imgId)
    }
    
    func saveMemberInterests(_ interests: [MemberInterestDTO]) {
        do {
            let encoded = try JSONEncoder().encode(interests)
            UserDefaults.standard.set(encoded, forKey: memberInterestsKey)
            print("✅ 멤버 관심사 데이터 로컬 저장 완료")
        } catch {
            print("❌ 멤버 관심사 데이터 저장 실패: \(error)")
        }
    }
    
    func getMemberInterests() -> [MemberInterestDTO]? {
        guard let data = UserDefaults.standard.data(forKey: memberInterestsKey) else { return nil }
        do {
            return try JSONDecoder().decode([MemberInterestDTO].self, from: data)
        } catch {
            print("❌ 멤버 관심사 데이터 디코딩 실패: \(error)")
            return nil
        }
    }
    
    func clearMemberInterests() {
        UserDefaults.standard.removeObject(forKey: memberInterestsKey)
        print("🗑️ 멤버 관심사 데이터 삭제")
    }
    
    func clearForLogout() {
        clearTokens()
        clearAppleLoginInfo()
        print("🔓 로그아웃 완료 - 토큰만 삭제 (사용자 기록 유지)")
        print("   → 유지된 데이터: MemberId, CurationData")
    }
    
    func clearForWithdraw() {
        clearTokens()
        clearOnboardingState()
        clearAppleLoginInfo()
        clearMemberInterests()
        UserDefaults.standard.removeObject(forKey: memberIdKey)
        UserDefaults.standard.removeObject(forKey: curationDataKey)
        UserDefaults.standard.removeObject(forKey: userNicknameKey)
        UserDefaults.standard.removeObject(forKey: userProfileImgIdKey)
        print("🗑️ 탈퇴 완료 - 모든 저장 데이터 초기화")
    }
    
    
    func printCurrentStatus() {
        print("=== Token Status ===")
        print("Access Token: \(getAccessToken() ?? "nil")")
        print("Token Valid: \(isTokenValid())")
        print("Onboarding Completed: \(isOnboardingCompleted())")
        print("===================")
    }
}
