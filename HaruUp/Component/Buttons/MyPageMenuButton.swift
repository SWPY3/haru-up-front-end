//
//  MyPageMenuButton.swift
//  HaruUp
//
//  Created by 하다현 on 12/30/25.
//

import UIKit

final class MyPageMenuButton: UIButton {
    init(title: String, hasArrow: Bool = true, isDestructive: Bool = false) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.setStyle(Typography.body1, text: title)
        titleLabel.textColor = isDestructive ? .red : .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        if hasArrow {
            let arrow = UIImageView(image: .chevronRight)
            arrow.tintColor = .neutral900
            arrow.translatesAutoresizingMaskIntoConstraints = false
            addSubview(arrow)
            
            NSLayoutConstraint.activate([
                arrow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                arrow.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                arrow.widthAnchor.constraint(equalToConstant: 16),
//                arrow.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// 관심사 태그 뷰
final class MyPageTagView: UIView {
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        layer.cornerRadius = 16
        
        label.setStyle(Typography.body4, text: "")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14)
        ])
    }
    
    func configure(text: String, emoji: String? = nil) {
        label.text = (emoji != nil) ? "\(emoji!) \(text)" : text
    }
    required init?(coder: NSCoder) { fatalError() }
}
