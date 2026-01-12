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
        stackView.spacing = 12
        
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
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private var imageTopConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    
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
        
        configureImage()
        configureText()
    }
    
    private func configureText() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, descriptionLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -18)
        ])
    }
    
    private func configureImage() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(page: OnboardingPageModel) {
        titleLabel.setStyledText(Typography.title2, fullText: page.title, highlightedText: page.highlightTitle, highlightedColor: .cta, defaultColor: .black)
        descriptionLabel.setStyle(Typography.body3, text: page.description)
        
        let image = page.image
        imageView.image = image
        
        // 이미지의 비율에 따라서 가득차게 구현
        imageHeightConstraint?.isActive = false
        let ratio = image.size.height / image.size.width
        imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio) // 높이 = 너비 * 비율
        imageHeightConstraint?.isActive = true
        
        layoutIfNeeded()
    }
}

