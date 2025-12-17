//
//  HomeHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 12/17/25.
//

import UIKit

final class HomeHeaderView: UIView {
    
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
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = .characterWhiteLevel1
        
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
    
    private let expProgressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = .neutral50
        view.progressTintColor = .primaryBlue700
        view.progress = 0.5
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
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
        configureStackView()
        configureAchievement()
        configureBubbleView()
        configureCharacter()
        configureCharacterInfo()
    }
    
    private func configureBackground() {
        self.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func configureStackView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func configureAchievement() {
        stackView.addArrangedSubview(achievementContainer)
        
        achievementContainer.addSubview(achievementStackView)
        achievementStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [achievemnetTitleLabel, achievementImageView, achievementLabel].forEach {
            achievementStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            achievementStackView.topAnchor.constraint(equalTo: achievementContainer.topAnchor, constant: 3),
            achievementStackView.bottomAnchor.constraint(equalTo: achievementContainer.bottomAnchor, constant: -3),
            achievementStackView.trailingAnchor.constraint(equalTo: achievementContainer.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureBubbleView() {
        stackView.setCustomSpacing(36, after: achievementContainer)
        
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
        stackView.setCustomSpacing(8, after: bubbleContainer)
        
        stackView.addArrangedSubview(characterImageView)
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
