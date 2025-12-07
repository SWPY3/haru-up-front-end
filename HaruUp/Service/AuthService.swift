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

final class AuthService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // for Apple Login
    private var currentNonce: String?
    private var appleLoginObserver: ((SingleEvent<Bool>) -> Void)?
    
    // MARK: Kakao Login
    func loginWithKakao() -> Single<Bool> {
        return Single.create { single in
            // KakaoTalk 앱 로그인 가능 여부
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
                    if let error = error {
                        print("카카오톡 로그인 에러:", error)
                        single(.failure(error))
                        return
                    }
                    
                    print("카카오톡 로그인 성공:", token ?? "")
                    self?.fetchUserInfo { result in
                        switch result {
                        case .success:
                            single(.success(true))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
                }
            } else {
                // 카카오계정(웹) 로그인
                UserApi.shared.loginWithKakaoAccount { [weak self] token, error in
                    if let error = error {
                        print("카카오계정 로그인 에러:", error)
                        single(.failure(error))
                        return
                    }
                    print("카카오계정 로그인 성공:", token ?? "")
                    self?.fetchUserInfo { result in
                        switch result {
                        case .success:
                            single(.success(true))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func fetchUserInfo(completion: @escaping (Result<Void, Error>) -> Void) { // TODO: 임의로 return 값을 로그인 여부 TRUE/FALSE로 구현
        UserApi.shared.me { user, error in
            if let error = error {
                print("유저 정보 가져오기 에러:", error)
                completion(.failure(error))
                return
            }
            print("유저 정보:", user ?? "")
            // 로그인 성공 후 다음 화면으로 이동하는 코드 넣으면 됨
            completion(.success(()))
        }
    }
    
    // MARK: Apple Login
    func loginWithApple() -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            guard let self else {
                single(.success(false))
                return Disposables.create()
            }
            
            self.appleLoginObserver = single
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
            appleLoginObserver?(.success(false))
            appleLoginObserver = nil

            return
        }
        
        // 1) 유저를 식별할 수 있는 고유 ID (서버나 로컬에 저장)
        let userIdentifier = credential.user
        
        // 2) 이름, 이메일 (처음 로그인 할 때만 올 수 있고, Hide my email 하면 nil 일 수 있음)
        let fullName = credential.fullName
        let email = credential.email
        
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
        
        print("🍎 Apple userIdentifier: \(userIdentifier)")
        print("🍎 email: \(String(describing: email))")
        print("🍎 identityToken: \(identityTokenString.prefix(20))...")
        print("🍎 authorizationCode: \(authorizationCodeString.prefix(20))...")
        print("🍎 nonce: \(nonce)")
        
        sendAppleLoginToServer(
                identityToken: identityTokenString,
                authorizationCode: authorizationCodeString,
                nonce: nonce,
                userIdentifier: userIdentifier
            )
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
    func loginWithNaver() -> Single<Bool> {
        return loginAndFetchProfile()
            .flatMap { profile -> Single<Bool> in
                
                // TODO: 여기서 서버 로그인/회원가입 API 호출
                // return apiClient.loginWithSocial(profile)
                //     .map { $0.success }
                
                // 지금은 네이버 로그인 + 프로필 조회 성공만으로 true
                return .just(true)
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
    func loginAndFetchProfile() -> Single<NaverUserProfile> {
        return login()
            .flatMap { [weak self] loginResult -> Single<NaverUserProfile> in
                guard let self = self else { return .never() }

                let accessToken = loginResult.accessToken.tokenString
                return self.fetchProfile(accessToken: accessToken)
            }
    }
    
}
