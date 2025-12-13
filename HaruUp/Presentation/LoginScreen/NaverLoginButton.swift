//
//  NaverLoginButton.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import UIKit


final class NaverLoginButton: UIButton {
    
    private let logoImageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()

        private let centerLabel: UILabel = {
            let lb = UILabel()
            lb.text = "네이버 로그인"
            lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            lb.textColor = .white
            lb.translatesAutoresizingMaskIntoConstraints = false
            return lb
        }()
    
    // init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                isHighlighted = false
            }
        }
    }
    
    private func setupButtonUI() {
        backgroundColor = .naverGreen
        layer.cornerRadius = 7
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        if let logo = UIImage(named: "btnG_아이콘사각") {
           
            logoImageView.image = logo
        }
        
        
        addSubview(logoImageView)
        addSubview(centerLabel)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
            
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 35),
            logoImageView.heightAnchor.constraint(equalToConstant: 35),
            
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
