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

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    
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
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
        
    }
    // MARK: - Selectors
    
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [kakaoLoginButton])
        stack.axis = .vertical
        stack.spacing = 10
        
        view.addSubview(stack)
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 28, paddingRight: 28)
    

    }
    
    private func bind() {
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
    
//    private func requestAdditionalScopes() {
//        // 1) 현재 계정에서 어떤 정보에 동의했는지 조회
//        UserApi.shared.me { [weak self] user, error in
//            if let error = error {
//                print("유저 정보 조회 오류: ", error)
//                return
//            }
//            guard let account = user?.kakaoAccount else {
//                self?.fetchUserInfo()
//                return
//            }
//            
//            // 2) 이메일, 프로필 이미지 등 스코프 체크
//            var scopesToRequest: [String] = []
//            
//            if account.profileNeedsAgreement == true {
//                scopesToRequest.append("profile")          // 프로필
//            }
//        }
//       
//    }
//    
}
