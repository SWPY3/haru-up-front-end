//
//  KakaoLoginButton.swift
//  HaruUp
//
//  Created by 조영현 on 12/30/25.
//

import UIKit

final class KakaoLoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString("카카오로 로그인")
        titleAttr.font = .systemFont(ofSize: 19, weight: .semibold)
        titleAttr.foregroundColor = .black
        config.attributedTitle = titleAttr
        
        let logoImage = UIImage(named: "kakao_logo")?.resized(to: CGSize(width: 20, height: 20))
        config.image = logoImage
        config.imagePlacement = .leading // 이미지 위치 (왼쪽)
        config.imagePadding = 8
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        self.configuration = config
        
        backgroundColor = .kakaoBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        
        contentHorizontalAlignment = .center
        semanticContentAttribute = .forceLeftToRight
        
    }
}
