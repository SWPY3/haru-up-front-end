//
//  OnboardingPageView.swift
//  HaruUp
//
//  Created by 조영현 on 12/30/25.
//

import UIKit

final class OnboardingPageView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .neutral700
        
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init frame")
        setupView()
    }
    
    convenience init(page: OnboardingPageModel) {
        self.init(frame: .zero)
        print("init page")
        configure(page: page)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        configureText()
        configureImage()
    }
    
    private func configureText() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, descriptionLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 56),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureImage() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 57),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func configure(page: OnboardingPageModel) {
        titleLabel.setStyledText(Typography.title2, fullText: page.title, highlightedText: page.highlightTitle, highlightedColor: .cta, defaultColor: .black)
        descriptionLabel.setStyle(Typography.body3, text: page.description)
        
        imageView.image = page.image
    }
}

