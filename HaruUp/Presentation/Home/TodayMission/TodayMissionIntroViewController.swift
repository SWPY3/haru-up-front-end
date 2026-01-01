//
//  TodayMissionIntroViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class TodayMissionIntroViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: TodayMissionIntroViewModel
    var onSelectMissionTap: (() -> Void)?
    
    private let gradientView: GradientBackgroundView = {
        let view = GradientBackgroundView(
            startColor: .introStart,
            endColor: .introEnd)
        view.alpha = 0.88
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.head2, text: "반가워요!")
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "AI가 추천해준 오늘의 미션들을\n선택하러 가볼까요?")
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        
        return label
    }()
    
    private let characterContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .characterTodayIntro
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        
        return imageView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("좋아요!", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.titleLabel?.textColor = .white
        button.backgroundColor = .cta
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.alpha = 0
        
        return button
    }()
    
    init(viewModel: TodayMissionIntroViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startEntranceAnimation()
    }
    
    private func setupView() {
        configureBackground()
        configureTitle()
        configureButton()
        configureImageView()
    }
    
    private func configureBackground() {
        view.backgroundColor = .introBackground
        
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureTitle() {
        [titleLabel, subtitleLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 169),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func configureImageView() {
        view.addSubview(characterContainerView)
        characterContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        characterContainerView.addSubview(characterImageView)
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor),
            characterContainerView.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            characterContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            characterContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            characterImageView.centerXAnchor.constraint(equalTo: characterContainerView.centerXAnchor),
            characterImageView.centerYAnchor.constraint(equalTo: characterContainerView.centerYAnchor)
        ])
    }
    
    private func configureButton() {
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func bind() {
        nextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                print("미션 목록 화면으로 이동")
                self.onSelectMissionTap?()
            }.disposed(by: disposeBag)
    }
    
    private func startEntranceAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.characterImageView.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.titleLabel.alpha = 1.0
                self.subtitleLabel.alpha = 1.0
                self.nextButton.alpha = 1.0
            }
        }
    }
}
