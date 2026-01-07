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
    private let userJobIdKey = "HaruUp_UserJobId"
    private let userJobDetailIdKey = "HaruUp_UserJobDetailId"
    // 화면 표시를 위해 이름도 저장
    private let userJobNameKey = "HaruUp_UserJobName"
    private let userJobDetailNameKey = "HaruUp_UserJobDetailName"
    
    // Apple 로그인 관련 키들
    private let appleUserIdKey = "HaruUp_AppleUserId"
    private let appleEmailKey = "HaruUp_AppleEmail"
    private let appleFullNameKey = "HaruUp_AppleFullName"
    
    private init() {}
    
    func saveToken(_ token: AuthToken) {
        KeychainHelper.shared.save(token: token.accessToken, forKey: accessTokenKey)
        
        if let refreshToken = token.refreshToken {
            KeychainHelper.shared.save(token: refreshToken, forKey: refreshTokenKey)
        }
        
        // 만료 시간은 민감 정보가 아니므로 UserDefaults 유지 (날짜 비교 편의성)
        if let expiresAt = token.expiresAt {
            UserDefaults.standard.set(expiresAt, forKey: tokenExpiresAtKey)
        }
    }
    
    func getAccessToken() -> String? {
        // 1. 먼저 Keychain(보안 저장소)에서 찾아봅니다. (신규 로직)
        if let token = KeychainHelper.shared.read(forKey: accessTokenKey) {
            return token
        }
        
        // 2. Keychain에 없다면? -> 혹시 구버전 사용자일 수 있으니 UserDefaults를 확인합니다.
        if let oldToken = UserDefaults.standard.string(forKey: accessTokenKey) {
            print("🔄 [Migration] 기존 Access Token 발견! Keychain으로 이동합니다.")
            
            // 3. 찾았다면 Keychain에 안전하게 옮겨 적습니다.
            KeychainHelper.shared.save(token: oldToken, forKey: accessTokenKey)
            
            // 4. 기존 취약한 공간(UserDefaults)에서는 지워줍니다.
            UserDefaults.standard.removeObject(forKey: accessTokenKey)
            
            return oldToken
        }
        
        // 둘 다 없으면 진짜 없는 것
        return nil
    }
    
    func getRefreshToken() -> String? {
        // 1. Keychain 확인
        if let token = KeychainHelper.shared.read(forKey: refreshTokenKey) {
            return token
        }
        
        // 2. UserDefaults 확인 (구버전 데이터)
        if let oldToken = UserDefaults.standard.string(forKey: refreshTokenKey) {
            print("🔄 [Migration] 기존 Refresh Token 발견! Keychain으로 이동합니다.")
            
            // 3. Keychain으로 이동
            KeychainHelper.shared.save(token: oldToken, forKey: refreshTokenKey)
            
            // 4. 기존 데이터 삭제
            UserDefaults.standard.removeObject(forKey: refreshTokenKey)
            
            return oldToken
        }
        
        return nil
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
        KeychainHelper.shared.delete(forKey: accessTokenKey)
        KeychainHelper.shared.delete(forKey: refreshTokenKey)
        
        
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
    
    // MARK: - Profile Management
    func saveProfile(nickname: String, jobId: Int?, jobName: String?, jobDetailId: Int?, jobDetailName: String?) {
        UserDefaults.standard.set(nickname, forKey: userNicknameKey)
        
        if let jobId = jobId { UserDefaults.standard.set(jobId, forKey: userJobIdKey) }
        if let jobName = jobName { UserDefaults.standard.set(jobName, forKey: userJobNameKey) }
        
        if let jobDetailId = jobDetailId { UserDefaults.standard.set(jobDetailId, forKey: userJobDetailIdKey) }
        if let jobDetailName = jobDetailName { UserDefaults.standard.set(jobDetailName, forKey: userJobDetailNameKey) }
        
        print("✅ 프로필 정보(닉네임/직업/세부직업) 로컬 저장 완료")
    }
    
    func getProfile() -> (nickname: String?, jobId: Int, jobName: String?, jobDetailId: Int, jobDetailName: String?) {
        let nickname = UserDefaults.standard.string(forKey: userNicknameKey)
        let jobId = UserDefaults.standard.integer(forKey: userJobIdKey)
        let jobName = UserDefaults.standard.string(forKey: userJobNameKey)
        let jobDetailId = UserDefaults.standard.integer(forKey: userJobDetailIdKey)
        let jobDetailName = UserDefaults.standard.string(forKey: userJobDetailNameKey)
        
        return (nickname, jobId, jobName, jobDetailId, jobDetailName)
    }
    
    func clearProfile() {
        UserDefaults.standard.removeObject(forKey: userNicknameKey)
        UserDefaults.standard.removeObject(forKey: userJobIdKey)
        UserDefaults.standard.removeObject(forKey: userJobNameKey)
        UserDefaults.standard.removeObject(forKey: userJobDetailIdKey)
        UserDefaults.standard.removeObject(forKey: userJobDetailNameKey)
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
        clearProfile()
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
