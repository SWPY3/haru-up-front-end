//
//  HomeSectionHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class HomeSectionHeaderView: UIView {
    
    var onTapInfo: (() -> Void)?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "오늘의 미션")
        label.textColor = .black
        
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.iconInfo, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return button
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "미션은 하루 최대 5개까지 선택할 수 있어요.")
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
        self.backgroundColor = .clear
        
        configureLabel()
    }
    
    private func configureLabel() {
        [stackView, subtitleLabel].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, infoButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
    }
}
