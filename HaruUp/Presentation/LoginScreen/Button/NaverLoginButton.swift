//
//  NaverLoginButton.swift
//  HaruUp
//
//  Created by 조영현 on 12/30/25.
//

import UIKit

final class NaverLoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .naverBackground
        setTitleColor(.white, for: .normal)
        
        setTitle("네이버로 로그인", for: .normal)
        titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        
        var logoImage = UIImage(named: "naver_logo")
        logoImage = logoImage?.resized(to: CGSize(width: 20, height: 20))
        
        setImage(logoImage, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        
        semanticContentAttribute = .forceLeftToRight
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        layer.cornerRadius = 16
        clipsToBounds = true
    }
}
