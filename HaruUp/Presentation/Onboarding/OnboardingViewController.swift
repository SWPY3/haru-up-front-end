//
//  OnboardingViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/2/25.
//

import UIKit

import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: OnboardingViewModel
    
    var onFinish: (() -> Void)? // Onboarding 완료 후 Home으로 이동 콜백
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("home", for: .normal)
        button.backgroundColor = .green
        
        return button
    }()
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        configureNextButton()
        bind()
    }
    
    private func configureNextButton() {
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        nextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                print("홈 화면 이동")
                self.onFinish?()
            }.disposed(by: disposeBag)
    }
}
