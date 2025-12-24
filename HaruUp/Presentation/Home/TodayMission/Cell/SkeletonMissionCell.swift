//
//  SkeletonMissionCell.swift
//  HaruUp
//
//  Created by 조영현 on 12/20/25.
//

import UIKit

final class SkeletonMissionCell: UITableViewCell {
    static let identifier: String = "SkeletonMissionCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        return view
    }()
    
    private let circleViewContainer: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        return view
    }()
    
    private let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        return view
    }()
    
    private let subtitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        return view
    }()
    
    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let difficultyView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        return view
    }()
    
    private let expView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        contentView.backgroundColor = .neutral10
        
        configureCard()
        configureCircleView()
        configureStackView()
        configureTitleStackView()
        configureBadgeStackView()
    }
    
    private func configureCard() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12), /// cell간 간격
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureCircleView() {
        cardView.addSubview(circleViewContainer)
        circleViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        circleViewContainer.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleViewContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            circleViewContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            circleViewContainer.heightAnchor.constraint(equalToConstant: 24),
            circleViewContainer.widthAnchor.constraint(equalToConstant: 24),
            
            circleView.centerXAnchor.constraint(equalTo: circleViewContainer.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: circleViewContainer.centerYAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 20),
            circleView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configureStackView() {
        cardView.addSubview(hStackView)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleStackView, badgeStackView].forEach {
            hStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            hStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30),
            hStackView.leadingAnchor.constraint(equalTo: circleViewContainer.trailingAnchor, constant: 10),
            hStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureTitleStackView() {
        [titleView, subtitleView].forEach {
            titleStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleView.heightAnchor.constraint(equalToConstant: 16),
            subtitleView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func configureBadgeStackView() {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.backgroundColor = .clear
        
        [difficultyView, expView, spacerView].forEach {
            badgeStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            difficultyView.widthAnchor.constraint(equalToConstant: 38),
            difficultyView.heightAnchor.constraint(equalToConstant: 16),
            expView.widthAnchor.constraint(equalToConstant: 68),
            expView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(index: Int) {
        let delay = Double(index) * 0.2 // 각 row에 따라 시작 delay 추가
        startPulsingAnimation(delay: delay)
    }

    private func startPulsingAnimation(delay: TimeInterval) {
        let opacityValues: [NSNumber] = [0.1, 0.3, 0.6, 0.8, 1.0, 0.8, 0.6, 0.3, 0.1]
        
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = opacityValues
        animation.keyTimes = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
        animation.duration = 2
        animation.repeatCount = .infinity
        animation.calculationMode = .cubic
        
        animation.beginTime = CACurrentMediaTime() + delay
        
        animation.fillMode = .backwards
        
        cardView.layer.removeAllAnimations()
        cardView.alpha = 0.1 // 기본 알파값
        cardView.layer.add(animation, forKey: "opacityPulse")
    }
}
