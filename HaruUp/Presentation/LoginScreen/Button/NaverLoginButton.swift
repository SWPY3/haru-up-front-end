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
        var config = UIButton.Configuration.plain()
        
        var titleAttr = AttributedString("네이버로 로그인")
        titleAttr.font = .systemFont(ofSize: 19, weight: .semibold)
        titleAttr.foregroundColor = UIColor(named: "appWhite") // 수정한 에셋 이름 적용
        config.attributedTitle = titleAttr
        
        let logoImage = UIImage(named: "naver_logo")?.resized(to: CGSize(width: 20, height: 20))
        config.image = logoImage
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        self.configuration = config
        
        backgroundColor = .naverBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        
        contentHorizontalAlignment = .center
        semanticContentAttribute = .forceLeftToRight

    }
}
