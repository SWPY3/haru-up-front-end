//
//  AuthService.swift
//  HaruUp
//
//  Created by 조영현 on 12/1/25.
//

import RxSwift

import KakaoSDKAuth
import KakaoSDKUser

import AuthenticationServices
import CryptoKit

import NidThirdPartyLogin
import Alamofire

final class AuthService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var authAPI: AuthAPIProtocol = AuthAPI()
    private var tokenStorage: TokenStorageService = TokenStorageService.shared
    
    
    init(authAPI: AuthAPIProtocol = AuthAPI(), tokenStorage: TokenStorageService = .shared) {
        self.authAPI = authAPI
        self.tokenStorage = tokenStorage
        super.init()
    }
    
    // for Apple Login
    private var currentNonce: String?
    private var appleLoginObserver: ((SingleEvent<SocialLoginResult>) -> Void)?
    private let disposeBag = DisposeBag()
    
    
    
    // MARK: Kakao Login
    
    private struct KakaoUserInfo {
        let accessToken: String
        let snsUserId: String
        let name: String?
        let email: String?
    }
    
    func loginWithKakao() -> Single<SocialLoginResult> {
        return loginWithKakaoSDK()
            .flatMap { [weak self] kakaoUserInfo -> Single<SocialLoginResult> in
                guard let self = self else {
                    return .just(SocialLoginResult(success: false, onboardingCompleted: false))
                }
                
                let request = SocialLoginRequestDTO(
                    loginType: SocialLoginProvider.kakao.rawValue,
                    snsId: kakaoUserInfo.snsUserId,
                    email: kakaoUserInfo.email ?? "",
                    name: kakaoUserInfo.name ?? ""
                )
                // 소셜 로그인 요청
                return self.sendSocialLoginToServer(request: request)
            }
    }
    
    private func loginWithKakaoSDK() -> Single<KakaoUserInfo> {
        return Single.create { single in
            let handleToken: (OAuthToken?) -> Void = { token in
                guard let accessToken = token?.accessToken else {
                    single(.failure(LoginError.invalidProfile))
                    return
                }
                self.fetchKakaoUserInfo(accessToken: accessToken) { result in
                    switch result {
                    case .success(let userInfo):
                        single(.success(userInfo))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            }
            
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    handleToken(token)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount{ token, error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    handleToken(token)
                }
            }
            return Disposables.create()
        }
    }
    
    private func fetchKakaoUserInfo(accessToken: String, completion: @escaping (Result<KakaoUserInfo, Error>) -> Void) {
        // TODO: 임의로 return 값을 로그인 여부
        UserApi.shared.me { user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = user else {
                completion(.failure(LoginError.invalidProfile)); return
            }
            
            
            let userInfo = KakaoUserInfo(
                accessToken: accessToken,
                snsUserId: String(user.id ?? 0),
                name: user.kakaoAccount?.profile?.nickname,
                email: user.kakaoAccount?.email ?? ""
            )
            completion(.success(userInfo))
        }
    }
    
    // MARK: Apple Login
    func loginWithApple() -> Single<SocialLoginResult> {
        return Single<SocialLoginResult>.create { [weak self] single in
            guard let self else {
                single(.success(SocialLoginResult(success: false, onboardingCompleted: false)))
                return Disposables.create()
            }
            
            self.appleLoginObserver = { event in
                switch event {
                case .success(let result):
                    single(.success(result))
                case .failure(let error):
                    single(.failure(error))
                }}
            
            self.startAppleLogin()
            
            return Disposables.create { [weak self] in
                self?.appleLoginObserver = nil
            }
        }
    }
    
    private func startAppleLogin() {
        // 1. provider & request 생성
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        // 2. 애플에게 어떤 정보 요청할지 설정 (이름, 이메일)
        request.requestedScopes = [.fullName, .email]
        
        // 3. nonce 생성 + SHA256 해시 후 요청에 넣기
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)
        request.nonce = hashedNonce
        
        // 3. 컨트롤러 생성 + delegate, presentationContext 지정
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // 4. 로그인 플로우 시작
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        print("🍎 애플 로그인 성공 콜백 들어옴")
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("애플 로그인 credential 캐스팅 실패")
            appleLoginObserver?(.success(SocialLoginResult(success: false, onboardingCompleted: false)))
            appleLoginObserver = nil
            
            return
        }
        
        // 1) 유저를 식별할 수 있는 고유 ID (서버나 로컬에 저장)
        let userIdentifier = credential.user
        
        
        // 2) 이름, 이메일 (처음 로그인 할 때만 올 수 있고, Hide my email 하면 nil 일 수 있음)
        let fullName = credential.fullName
        let email = credential.email
        
        
        let name = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        
        tokenStorage.saveAppleUserInfo(
            userId: userIdentifier,
            email: email,  // 최초 로그인 시에만 있음, 이후엔 nil
            fullName: name.isEmpty ? nil : name  // 최초 로그인 시에만 있음
        )
        
        print("✅ Apple 로그인 정보 로컬 저장 완료")
        print("   - userId: \(userIdentifier)")
        print("   - email: \(email ?? "nil")")
        print("   - fullName: \(name.isEmpty ? "nil" : name)")
        
        // 3) 서버 연동할 때 쓰는 토큰들 (JWT / code)
        guard let identityTokenData = credential.identityToken,
              let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
            print("identityToken 변환 실패")
            return
        }
        
        guard let authorizationCodeData = credential.authorizationCode,
              let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) else {
            print("authorizationCode 변환 실패")
            return
        }
        guard let nonce = currentNonce else {
            print("currentNonce 없음")
            return
        }
        
        
        let request = SocialLoginRequestDTO(
            loginType: SocialLoginProvider.apple.rawValue,
            snsId: userIdentifier,
            email: email ?? "",
            name: name.isEmpty ? "" : name,
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString,
            nonce: nonce
        )
        
        print("🍎 Apple userIdentifier: \(userIdentifier)")
        print("🍎 email: \(String(describing: email))")
        print("🍎 identityToken: \(identityTokenString.prefix(20))...")
        print("🍎 authorizationCode: \(authorizationCodeString.prefix(20))...")
        print("🍎 nonce: \(nonce)")
        
        
        sendSocialLoginToServer(request: request)
            .subscribe(onSuccess: { [weak self] result in
                self?.appleLoginObserver?(.success(result))
                self?.appleLoginObserver = nil
            }, onFailure: { [weak self] error in
                self?.appleLoginObserver?(.failure(error))
                self?.appleLoginObserver = nil
            })
            .disposed(by: disposeBag)
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("애플 로그인 실패: \(error.localizedDescription)")
        // 필요하면 UIAlert 띄우면 됨
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
    
    // 랜덤 nonce 문자열 생성
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        
        return result
    }
    
    // 문자열을 SHA256 해시로 변환
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    
    private func sendAppleLoginToServer(
        identityToken: String,
        authorizationCode: String,
        nonce: String,
        userIdentifier: String
    ) {
        
    }
    
    
    
    // MARK: - Naver Login
    func loginWithNaver() -> Single<SocialLoginResult> {
        return loginAndFetchProfile()
            .flatMap { [weak self] profile -> Single<SocialLoginResult> in
                guard let self = self else {
                    return .just(SocialLoginResult(success: false, onboardingCompleted: false))
                }
                
                let request = SocialLoginRequestDTO(
                    loginType: SocialLoginProvider.naver.rawValue,
                    snsId: profile.id,
                    email: profile.email ?? "",
                    name: profile.name ?? ""
                )
                
                return self.sendSocialLoginToServer(request: request)
            }
    }
    
    // 1) 네이버 로그인 (토큰 발급)
    func login() -> Single<LoginResult> {
        return Single.create { single in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case .success(let loginResult):
                    single(.success(loginResult))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    
    
    
    // 2) 프로필 조회
    func fetchProfile(accessToken: String) -> Single<NaverUserProfile> {
        return Single.create { single in
            NidOAuth.shared.getUserProfile(accessToken: accessToken) { result in
                switch result {
                case .success(let dict):
                    if let profile = NaverUserProfile(dictionary: dict) {
                        single(.success(profile))
                    } else {
                        single(.failure(LoginError.invalidProfile))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    // 3) 로그인 + 프로필 한 번에
    private func loginAndFetchProfile() -> Single<NaverUserProfileWithToken> {
        return login()
            .flatMap { [weak self] loginResult -> Single<NaverUserProfileWithToken> in
                guard let self = self else { return .never() }
                
                let accessToken = loginResult.accessToken.tokenString
                return self.fetchProfile(accessToken: accessToken)
                    .map { profile in
                        NaverUserProfileWithToken(profile: profile, accessToken: accessToken)
                    }
            }
    }
    
    private struct NaverUserProfileWithToken {
        let profile: NaverUserProfile
        let accessToken: String
        
        var id: String { profile.id }
        var name: String? { profile.name }
        var email: String? { profile.email }
    }
    
    // MARK:  공통 백엔드 API 호출
    private func sendSocialLoginToServer(request: SocialLoginRequestDTO) -> Single<SocialLoginResult> {
        print("백엔드 호출 요청: \(request)")
        
        return authAPI.socialLogin(request: request)
            .map { [weak self] responseDTO in
                print("🔥 sns-loginAPI response: \(responseDTO)")
                
                guard responseDTO.success,
                      let data = responseDTO.data else {
                    print("❌ 로그인 실패: response.success = false 또는 data 없음")
                    if let errorMessage = responseDTO.errorMessage {
                        print("❌ 에러 메시지: \(errorMessage)")
                    }
                    return SocialLoginResult(success: false, onboardingCompleted: false)
                }
                
                // 1. AccessToken / RefreshToken 발급 및 저장
                let authToken = AuthToken(
                    accessToken: data.accessToken,
                    refreshToken: data.refreshToken
                )
                
                self?.tokenStorage.saveToken(authToken)
                print("✅ 토큰 저장 완료")
                
                // 2. MemberId 저장
                let memberId = String(data.id)
                self?.tokenStorage.saveMemberId(memberId)
                print("✅ MemberId 저장: \(memberId)")
                
                // 3. 다른 계정으로 로그인했다면 온보딩 상태 초기화
                self?.tokenStorage.clearOnboardingIfDifferentUser(currentMemberId: memberId)
                
                
                let onboardingCompleted = self?.tokenStorage.isOnboardingCompleted() ?? false
                
                // 화면 분기를 위한 결과 반환
                return SocialLoginResult(
                    success: true,
                    onboardingCompleted: onboardingCompleted
                )
            }
    }
    
    // MARK: Profile & Interests Recovery
    func fetchProfileAndInterests() -> Single<Bool> {
        // Single.zip을 사용하여 두 API를 동시에 호출 (병렬 처리)
        return Single.zip(fetchProfile(), fetchMemberInterests())
            .map { profileData, interests in
                
                // 1. 프로필 정보 저장 (저장 로직 추가됨)
                TokenStorageService.shared.saveProfile(
                    nickname: profileData.nickname,
                    imgId: profileData.imgId
                )
                
                // 2. 관심사 정보 저장
                TokenStorageService.shared.saveMemberInterests(interests)
                
                print("🚀 [데이터 복구 완료]")
                print(" - 닉네임: \(profileData.nickname)")
                print(" - 관심사: \(interests.count)개")
                
                return true
            }
            .do(onError: { error in
                print("❌ 프로필/관심사 데이터 복구 실패: \(error)")
            })
    }
    
    // [수정] 백엔드 프로필 조회 (public으로 변경 및 자동 저장 추가)
    func fetchProfile() -> Single<ProfileData> {
        return Single.create { [weak self] single in
            guard let token = self?.tokenStorage.getAccessToken() else {
                single(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "토큰이 없습니다"])))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(
                NetworkDefine.ProfileAPI.getProfile.url,
                method: .get,
                headers: headers
            )
            .validate()
            .responseDecodable(of: ProfileResponse.self) { response in
                switch response.result {
                case .success(let profileResponse):
                    if let profileData = profileResponse.data {
                        print("✅ 프로필 조회 성공: \(profileData.nickname)")
                        single(.success(profileData))
                    } else {
                        let error = NSError(
                            domain: "AuthService",
                            code: 500,
                            userInfo: [NSLocalizedDescriptionKey: profileResponse.errorMessage ?? "프로필 조회 실패"]
                        )
                        single(.failure(error))
                    }
                    
                case .failure(let error):
                    print("❌ 프로필 조회 API 실패: \(error)")
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
        .do(onSuccess: { [weak self] profileData in
            // 💾 [추가] 조회 성공 시 자동으로 로컬 스토리지에 저장
            self?.tokenStorage.saveProfile(
                nickname: profileData.nickname,
                imgId: profileData.imgId
            )
            print("💾 [AuthService] 프로필 정보 로컬 최신화 완료")
        })
    }
    
    // [수정] 멤버 관심사 조회 (public으로 변경 및 자동 저장 추가)
    func fetchMemberInterests() -> Single<[MemberInterestDTO]> {
        return Single.create { [weak self] single in
            guard let token = self?.tokenStorage.getAccessToken() else {
                single(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "토큰이 없습니다"])))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(
                NetworkDefine.InterestsAPI.member.url,
                method: .get,
                headers: headers
            )
            .validate()
            .responseDecodable(of: MemberInterestResponse.self) { response in
                switch response.result {
                case .success(let interestResponse):
                    print("✅ 관심사 조회 성공: \(interestResponse.totalCount)개")
                    single(.success(interestResponse.interests))
                    
                case .failure(let error):
                    print("❌ 관심사 조회 API 실패: \(error)")
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
        .do(onSuccess: { [weak self] interests in
            // 💾 [추가] 조회 성공 시 자동으로 로컬 스토리지에 저장
            self?.tokenStorage.saveMemberInterests(interests)
            print("💾 [AuthService] 관심사 정보 로컬 최신화 완료")
        })
    }
}

