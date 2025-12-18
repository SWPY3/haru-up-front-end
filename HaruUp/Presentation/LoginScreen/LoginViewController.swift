//
//  LoginViewController.swift
//  HaruUp
//
//  Created by 하다현 on 11/27/25.
//

import UIKit

import RxSwift
import RxCocoa

import AuthenticationServices

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: LoginViewModel
    
//    let naverLoginButton = NaverLoginButton()
    
    var onFinish: ((SocialLoginResult) -> Void)? // Login 완료 후 Onboarding으로 이동 콜백
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "haruUp_logo")
        return iv
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "kakao_login"), for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }()
    
    private let naverLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "naver_login"), for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "apple_login"), for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }()
    
//    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
//        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
//        button.cornerRadius = 8
//        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        return button
//    }()
    
    
    
    // MARK: 로그인 완료 후 온보딩으로 넘어가는 onFinish 클로저 작동용 버튼
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("onboarding", for: .normal)
        button.backgroundColor = .green
        
        return button
    }()
    
    
    
    
    private var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        //        logoImageView.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [kakaoLoginButton, naverLoginButton, appleLoginButton])
        stack.axis = .vertical
        stack.spacing = 19
        
        view.addSubview(stack)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        stack.anchor(
            top: logoImageView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 130,
            paddingLeft: 28,
            paddingRight: 28)
        
    }
    
    // MARK: - bind
    private func bind() {
        let input = LoginViewModel.Input(
            kakaoLoginTapped: kakaoLoginButton.rx.tap.asObservable(),
            appleLoginTapped: appleLoginButton.rx.controlEvent(.touchUpInside).asObservable(),
            naverLoginTapped: naverLoginButton.rx.tap.asObservable()
            
        )
        
        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.indicatorView.startAnimating()
                } else {
                    self?.indicatorView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(onNext: { [weak self] message in
                // TODO: 에러 표시 방법
                print("로그인 에러: \(message)")
            })
            .disposed(by: disposeBag)
        
        output.loginSuccess
            .emit(onNext: { [weak self] result in
                print("🟢 로그인 성공!")
                print("   onboardingCompleted: \(result.onboardingCompleted)")
                print("   onFinish 클로저 존재 여부: \(self?.onFinish != nil)")
                
                self?.onFinish?(result)
                print("   onFinish 호출 완료")
            })
            .disposed(by: disposeBag)
    }
}
