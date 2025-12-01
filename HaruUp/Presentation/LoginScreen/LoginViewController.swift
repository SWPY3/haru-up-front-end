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
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [kakaoLoginButton, appleLoginButton])
        stack.axis = .vertical
        stack.spacing = 10
        
        view.addSubview(stack)
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 28, paddingRight: 28)
    

    }
    
    // MARK: - bind
    private func bind() {
        let input = LoginViewModel.Input(
            kakaoLoginTapped: kakaoLoginButton.rx.tap.asObservable(),
            appleLoginTapped: appleLoginButton.rx.controlEvent(.touchUpInside).asObservable()
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
            .emit(onNext: { [weak self] _ in
                // TODO: 온보딩 화면 이동
                print("로그인 성공!")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    private func goToHome() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        
        guard let window = view.window else { return }
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
    }
}
