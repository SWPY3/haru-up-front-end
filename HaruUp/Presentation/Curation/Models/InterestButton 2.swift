//
//  InterestButton.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit

class InterestButton: UIButton {
    
    private var isInterestSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    // 아이콘을 표시할 ImageView
//    private let iconImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
    
    // 아이콘 텍스트 Label
    private let iconTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 텍스트를 표시할 Label
    private let interestTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        backgroundColor = .systemGray6
        
        // ImageView와 Label 추가
        addSubview(iconTextLabel)
        addSubview(interestTitleLabel)
        
        // 제약 조건
        NSLayoutConstraint.activate([
            // 아이콘: 왼쪽에서 20pt, 세로 중앙
            iconTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconTextLabel.widthAnchor.constraint(equalToConstant: 24),
            iconTextLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // 텍스트: 아이콘 오른쪽, 세로 중앙
            interestTitleLabel.leadingAnchor.constraint(equalTo: iconTextLabel.trailingAnchor, constant: 12),
            interestTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            interestTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
        
    }
    
    // 아이콘과 텍스트 설정
    func configure(icon: String, title: String) {
        iconTextLabel.text = icon
        interestTitleLabel.text = title
    }
    
    func setSelected(_ selected: Bool) {
        isInterestSelected = selected
    }
    
    private func updateAppearance() {
        UIView.animate(withDuration: 0.2) {
            if self.isInterestSelected {
                self.layer.borderColor = UIColor.systemBlue.cgColor
                self.layer.borderWidth = 2
                self.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
            } else {
                self.layer.borderColor = nil
                self.layer.borderWidth = 0
                self.backgroundColor = .systemGray6
            }
        }
    }
}
