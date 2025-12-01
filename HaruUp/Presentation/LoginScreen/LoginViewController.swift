//
//  LoginViewController.swift
//  HaruUp
//
//  Created by 하다현 on 11/27/25.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser

import RxSwift
import RxCocoa

import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var currentNonce: String?
    
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "ex_logo")
        return iv
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
        
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindKakao()
        bindApple()
        
    }
    // MARK: - Selectors
    
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [kakaoLoginButton, appleLoginButton])
        stack.axis = .vertical
        stack.spacing = 10
        
        view.addSubview(stack)
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 28, paddingRight: 28)
    

    }
    
    // MARK: - Kakao Login
    private func bindKakao() {
        kakaoLoginButton.rx.tap
            .bind { [ weak self ] in
                self?.loginWithKakao()
            }
            .disposed(by: disposeBag)
    }
    
    private func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
                if let error = error {
                    print("카카오톡 로그인 에러:", error)
                    return
                }
                print("카카오톡 로그인 성공:", token ?? "")
                self?.fetchUserInfo()
            }
        } else {
            // 카카오계정(웹) 로그인
            UserApi.shared.loginWithKakaoAccount { [weak self] token, error in
                if let error = error {
                    print("카카오계정 로그인 에러:", error)
                    return
                }
                print("카카오계정 로그인 성공:", token ?? "")
                self?.fetchUserInfo()
            }
        }
    }
    
    private func fetchUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print("유저 정보 가져오기 에러:", error)
                return
            }
            print("유저 정보:", user ?? "")
            // 로그인 성공 후 다음 화면으로 이동하는 코드 넣으면 됨
        }
    }
    
    // MARK: - Apple Login
    private func bindApple() {
        appleLoginButton.rx.controlEvent(.touchUpInside)
            .bind { [ weak self ] in
                self?.startAppleLogin()
            }
            .disposed(by: disposeBag)
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
        
        goToHome()

    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("애플 로그인 실패: \(error.localizedDescription)")
        // 필요하면 UIAlert 띄우면 됨
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? ASPresentationAnchor()
    }
    
    // MARK: - Navigation
    private func goToHome() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        
        guard let window = view.window else { return }
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
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
    
}
