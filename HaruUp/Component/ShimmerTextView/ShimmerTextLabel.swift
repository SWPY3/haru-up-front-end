//
//  ShimmerTextLabel.swift
//  HaruUp
//
//  Created by 하다현 on 6/3/26.
//

import UIKit

class ShimmerTextLabel: UIView {
    
    // MARK: - UI Components
    private let baseLabel = UILabel()
    private let shinyLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    var text: String? {
        didSet {
            baseLabel.text = text
            shinyLabel.text = text
        }
    }
    
    var font: UIFont = Typography.body4.font {
        didSet {
            baseLabel.font = font
            shinyLabel.font = font
        }
    }
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            baseLabel.textAlignment = textAlignment
            shinyLabel.textAlignment = textAlignment
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
        setupUI()
    }
    
    private func setupUI() {
        baseLabel.numberOfLines = 0
        baseLabel.textColor = .black
        addSubview(baseLabel)

        shinyLabel.numberOfLines = 0
        shinyLabel.textColor = .neutral50
        addSubview(shinyLabel)
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        // 시작 위치를 화면 왼쪽 밖으로 설정 (기본값인 가운데 고정 방지)
        gradientLayer.locations = [-1.0, -0.5, 0.0] as [NSNumber]

        shinyLabel.layer.mask = gradientLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 뷰의 크기에 맞게 라벨과 레이어 크기 조정
        baseLabel.frame = bounds
        shinyLabel.frame = bounds
        gradientLayer.frame = bounds
    }
    
    // MARK: - Animation
    func startShimmering() {
        // 이미 애니메이션이 있다면 제거
        gradientLayer.removeAnimation(forKey: "shimmer")
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0] as [NSNumber]
        animation.toValue = [1.0, 1.5, 2.0] as [NSNumber]
        animation.duration = 3.0
        animation.repeatCount = .infinity
        
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    func stopShimmering() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }

}
