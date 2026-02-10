//
//  NotificationSettingViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/16/26.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationSettingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = NotificationSettingViewModel()
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let switchToggledSubject = PublishSubject<Bool>()
    
    private let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.chevronLeft, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "알림 설정")
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral10
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let notiTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "앱 푸시 알림")
        label.textColor = .black
        return label
    }()
    
    private let notiDescriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "진행중인 미션의 리마인드 안내를\n푸시 알림으로 받으실 수 있습니다.")
        label.textColor = .neutral800
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [notiTitleLabel, notiDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    private let notificationSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .cta
        sw.isOn = true // 기본값
        return sw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        bind()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.onNext(())
        
        var parent = self.parent
        while parent != nil {
            if let tabBar = parent as? MainTabBarController {
                tabBar.setTabBarHidden(true, animated: animated)
                break
            }
            parent = parent?.parent
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var parent = self.parent
        while parent != nil {
            if let tabBar = parent as? MainTabBarController {
                tabBar.setTabBarHidden(false, animated: animated)
                break
            }
            parent = parent?.parent
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        [customNavBar, backButton, navTitleLabel, notificationContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [backButton, navTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            customNavBar.addSubview($0)
        }
        
        [textStackView, notificationSwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            notificationContainerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 56),
            
            backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            navTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 13),
            
            notificationContainerView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 21),
            notificationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notificationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            notificationSwitch.topAnchor.constraint(equalTo: notiDescriptionLabel.topAnchor),
            notificationSwitch.trailingAnchor.constraint(equalTo: notificationContainerView.trailingAnchor, constant: -20),
            
            textStackView.topAnchor.constraint(equalTo: notificationContainerView.topAnchor, constant: 18),
            textStackView.bottomAnchor.constraint(equalTo: notificationContainerView.bottomAnchor, constant: -18),
            textStackView.leadingAnchor.constraint(equalTo: notificationContainerView.leadingAnchor, constant: 20),
            
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: notificationSwitch.leadingAnchor, constant: -20)
        ])
    }
    
    private func bind() {
        backButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        notificationSwitch.rx.isOn
            .skip(1)  // 초기값 무시
            .bind(to: switchToggledSubject)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = NotificationSettingViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            switchToggled: switchToggledSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 초기 스위치 상태 설정
        output.initialSwitchState
            .drive(notificationSwitch.rx.isOn)
            .disposed(by: disposeBag)
        
        // 설정 저장 완료 (필요시 피드백 제공)
        output.settingSaved
            .drive(with: self, onNext: { owner, isEnabled in
                print("알림 설정 변경됨: \(isEnabled)")
                // 필요하면 여기서 토스트 메시지 표시
            })
            .disposed(by: disposeBag)
    }
}
