//
//  SplashViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/11/25.
//

import UIKit
import RxSwift

class SplashViewController: UIViewController {
    
    let viewModel: SplashViewModel
    private let disposeBag = DisposeBag()
    
    // coordinator에게 결과 전달
    var onAuthCheckCompleted: ((SplashResult) -> Void)?
    
    private let gradientView: GradientBackgroundView = {
        let view = GradientBackgroundView(
            startColor: .splashStart,
            endColor: .splashEnd)
        
        return view
    }()
    
    private let logoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        
        return stackView
    }()
    
    let mainLogoImage: UIImageView = {
        let iv = UIImageView()
        iv.image = .splashLogo
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let mainLogoTitle: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .splashAppName
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 인증 상태 확인
        viewModel.checkAuthStatus()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.onAuthCheckCompleted?(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        
        configureBackground()
        configureMainLogo()
    }
    
    private func configureBackground() {
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureMainLogo() {
        gradientView.addSubview(logoStackView)
        logoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [mainLogoImage, mainLogoTitle].forEach {
            logoStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            logoStackView.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor),
            logoStackView.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor)
        ])
    }

}
