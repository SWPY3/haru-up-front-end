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
    
    var onFinish: ((SocialLoginResult) -> Void)? // Login 완료 후 Onboarding으로 이동 콜백
    
    /// background Image의 사이즈를 비율에 따라 맞춰서 정하기 위해 구현
    private var backgroundAspectConstraint: NSLayoutConstraint?
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = .imageLoginBackground

        return iv
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        
        return stackView
    }()
    
    private let kakaoLoginButton = KakaoLoginButton()
    private let naverLoginButton = NaverLoginButton()
    private let appleLoginButton: UIControl = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 16
        
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
        
        setupView()
        bind()
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        configureTitle()
        configureButton()
        
        applyBackgroundAspect()
    }
    
    private func applyBackgroundAspect() {
        guard let backgroundImage = logoImageView.image else { return }
        
        let ratio = backgroundImage.size.height / backgroundImage.size.width
        backgroundAspectConstraint?.isActive = false
        backgroundAspectConstraint = logoImageView.heightAnchor.constraint(
            equalTo: logoImageView.widthAnchor,
            multiplier: ratio
        )
        backgroundAspectConstraint?.priority = .required
        backgroundAspectConstraint?.isActive = true
    }
    
    private func configureTitle() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func configureButton() {
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [kakaoLoginButton, naverLoginButton, appleLoginButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 36),
            buttonStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -96),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 54),
            naverLoginButton.heightAnchor.constraint(equalToConstant: 54),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 54),
        ])
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

