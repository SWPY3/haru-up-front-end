//
//  LoadingButtonView.swift
//  HaruUp
//
//  Created by 조영현 on 12/20/25.
//

import UIKit

final class LoadingButtonView: UIView {
    
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral500
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "미션 생성 중")
        label.textColor = .neutral100
        
        return label
    }()
    
    private let dot1: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: ".")
        label.textColor = .neutral100
        
        return label
    }()
    
    private let dot2: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: ".")
        label.textColor = .neutral100
        
        return label
    }()
    
    private let dot3: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: ".")
        label.textColor = .neutral100
        
        return label
    }()
    
    private lazy var dots = [dot1, dot2, dot3]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        startJumpingAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        self.backgroundColor = .neutral10
        
        configureView()
        configureLabel()
    }
    
    private func configureView() {
        self.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            buttonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            buttonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func configureLabel() {
        buttonView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [title, dot1, dot2, dot3].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.setCustomSpacing(4, after: title)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor)
        ])
    }
    
    private func startJumpingAnimation() {
        // 각 점마다 반복
        for (index, dot) in dots.enumerated() {
            
            let delay = Double(index) * 0.2 // delay: 0.2
            
            UIView.animateKeyframes(withDuration: 1.0, delay: delay, options: [.repeat]) {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                    dot.transform = CGAffineTransform(translationX: 0, y: -3)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    dot.transform = .identity
                }
            }
        }
    }
}
