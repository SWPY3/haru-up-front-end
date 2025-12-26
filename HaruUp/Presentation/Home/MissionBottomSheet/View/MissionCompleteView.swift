//
//  MissionCompleteView.swift
//  HaruUp
//
//  Created by 조영현 on 12/27/25.
//

import UIKit

final class MissionCompleteView: UIView {
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "🎉 미션 완료 🎉")
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body1, text: "250 경험치를 획득했어요!\n오늘도 한걸음 성장했어요 ✨")
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .cta
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = Typography.body3.font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        configureBackgroundView()
        configureContent()
    }
    
    private func configureBackgroundView() {
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureContent() {
        backgroundView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, descriptionLabel, confirmButton].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 40),
            contentStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 30),
            contentStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -30),
            contentStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -29),
            
            confirmButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        contentStackView.setCustomSpacing(20, after: titleLabel)
        contentStackView.setCustomSpacing(22, after: descriptionLabel)
    }
    
    func configure(exp: Int) {
        let highlight = "\(exp)"
        let full = "\(exp) 경험치를 획득했어요!\n오늘도 한걸음 성장했어요 ✨"

        descriptionLabel.setStyledText(
            Typography.body1,
            fullText: full,
            highlightedText: highlight,
            highlightedColor: .cta,
            defaultColor: .neutral900
        )
    }
}
