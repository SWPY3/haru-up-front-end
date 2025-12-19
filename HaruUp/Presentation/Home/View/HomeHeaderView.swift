//
//  HomeHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 12/17/25.
//

import UIKit

final class HomeHeaderView: UIView {
    
    /// background Image의 사이즈를 비율에 따라 맞춰서 정하기 위해 구현
    private var backgroundAspectConstraint: NSLayoutConstraint?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = .imageHomeBackgroundDay
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let achievementContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let achievementStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    
    private let achievemnetTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "연속 미션 달성일")
        label.textColor = .black
        
        return label
    }()
    
    private let achievementImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = .iconFireActive
        
        return imageView
    }()
    
    private let achievementLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "0")
        label.textColor = .black
        
        return label
    }()
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let bubbleView: SpeechBubbleView = {
        let view = SpeechBubbleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let characterContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = .characterWhiteLevel1
        
        return imageView
    }()
    
    private let characterShadowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = .characterShadow
        
        return imageView
    }()
    
    private let characterInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let levelNameContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let levelNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let characterLevelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral400
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        return view
    }()
    
    private let characterLevelLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.level, text: "Lv. 1")
        label.textColor = .white
        
        return label
    }()
    
    private let characterNameLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "꾸준한 하루")
        label.textColor = .black
        
        return label
    }()
    
    private let expContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let expStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let expProgressView: RoundedProgressView = {
        let view = RoundedProgressView()
        view.setColors(trackTintColor: .white, trackBorderColor: .neutral50, progressColor: .primaryBlue700)

        return view
    }()
    
    private let expLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        
        return stackView
    }()
    
    private let currentExpLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption1, text: "50")
        label.textColor = .primaryBlue700
        
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption1, text: "/")
        label.textColor = .neutral500
        
        return label
    }()
    
    private let maxExpLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption1, text: "250")
        label.textColor = .neutral500
        
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption1, text: "EXP")
        label.textColor = .neutral500
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        configureBackground()
        configureAchievement()
        configureStackView()
        configureBubbleView()
        configureCharacter()
        configureCharacterInfo()
        
        applyBackgroundAspect()
        
        expProgressView.progress = 0.5
    }

    private func applyBackgroundAspect() {
        guard let backgroundImage = backgroundImageView.image else { return }
        let ratio = backgroundImage.size.height / backgroundImage.size.width

        /// 기존의 제약 조건 비활성화 후, 다시 생성 후 적용
        backgroundAspectConstraint?.isActive = false
        backgroundAspectConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: ratio)
        backgroundAspectConstraint?.priority = .required
        backgroundAspectConstraint?.isActive = true
    }
    
    private func configureBackground() {
        self.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func configureStackView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: achievementContainer.bottomAnchor, constant: 36),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func configureAchievement() {
        self.addSubview(achievementContainer)
        achievementContainer.translatesAutoresizingMaskIntoConstraints = false
        
        achievementContainer.addSubview(achievementStackView)
        achievementStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [achievemnetTitleLabel, achievementImageView, achievementLabel].forEach {
            achievementStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            achievementContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            achievementContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            achievementContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            achievementStackView.topAnchor.constraint(equalTo: achievementContainer.topAnchor, constant: 3),
            achievementStackView.bottomAnchor.constraint(equalTo: achievementContainer.bottomAnchor, constant: -3),
            achievementStackView.trailingAnchor.constraint(equalTo: achievementContainer.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureBubbleView() {
        stackView.addArrangedSubview(bubbleContainer)
        
        bubbleContainer.addSubview(bubbleView)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleView.setText("오늘 하루도 함께 나아가볼까요?")
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: bubbleContainer.topAnchor),
            bubbleView.centerXAnchor.constraint(equalTo: bubbleContainer.centerXAnchor),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: bubbleContainer.leadingAnchor, constant: 20),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: bubbleContainer.trailingAnchor, constant: -20),
            bubbleView.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor),
            bubbleView.heightAnchor.constraint(equalToConstant: 44 + bubbleView.tailSize.height)
        ])
    }
    
    private func configureCharacter() {
        stackView.setCustomSpacing(20, after: bubbleContainer)
        
        stackView.addArrangedSubview(characterContainer)
        
        [characterShadowImageView, characterImageView].forEach {
            characterContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: characterContainer.topAnchor),
            characterImageView.bottomAnchor.constraint(equalTo: characterContainer.bottomAnchor),
            characterImageView.leadingAnchor.constraint(equalTo: characterContainer.leadingAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: characterContainer.trailingAnchor),
            
            characterShadowImageView.bottomAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: -3),
            characterShadowImageView.leadingAnchor.constraint(equalTo: characterImageView.centerXAnchor, constant: -32)
        ])
    }
    
    private func configureCharacterInfo() {
        stackView.setCustomSpacing(27, after: characterImageView)
        
        stackView.addArrangedSubview(characterInfoStackView)
        
        [levelNameContainer, expContainer].forEach {
            characterInfoStackView.addArrangedSubview($0)
        }
        
        configureLevelName()
        configureExpLabel()
    }
    
    private func configureLevelName() {
        levelNameContainer.addSubview(levelNameStackView)
        levelNameStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [characterLevelContainer, characterNameLabel].forEach {
            levelNameStackView.addArrangedSubview($0)
        }
        
        characterLevelContainer.addSubview(characterLevelLabel)
        characterLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterLevelLabel.topAnchor.constraint(equalTo: characterLevelContainer.topAnchor, constant: 2),
            characterLevelLabel.bottomAnchor.constraint(equalTo: characterLevelContainer.bottomAnchor, constant: -2),
            characterLevelLabel.leadingAnchor.constraint(equalTo: characterLevelContainer.leadingAnchor, constant: 8),
            characterLevelLabel.trailingAnchor.constraint(equalTo: characterLevelContainer.trailingAnchor, constant: -8),
            
            levelNameStackView.topAnchor.constraint(equalTo: levelNameContainer.topAnchor),
            levelNameStackView.bottomAnchor.constraint(equalTo: levelNameContainer.bottomAnchor),
            levelNameStackView.centerXAnchor.constraint(equalTo: levelNameContainer.centerXAnchor)
        ])
    }
    
    private func configureExpLabel() {
        expContainer.addSubview(expStackView)
        expStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [expProgressView, expLabelStackView].forEach {
            expStackView.addArrangedSubview($0)
        }
        
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.backgroundColor = .clear
        
        [spacerView, currentExpLabel, separatorLabel, maxExpLabel, unitLabel].forEach {
            expLabelStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            expProgressView.heightAnchor.constraint(equalToConstant: 12),
            
            expStackView.topAnchor.constraint(equalTo: expContainer.topAnchor, constant: 8),
            expStackView.bottomAnchor.constraint(equalTo: expContainer.bottomAnchor, constant: -8),
            expStackView.leadingAnchor.constraint(equalTo: expContainer.leadingAnchor, constant: 20),
            expStackView.trailingAnchor.constraint(equalTo: expContainer.trailingAnchor, constant: -20),
        ])
    }
}
