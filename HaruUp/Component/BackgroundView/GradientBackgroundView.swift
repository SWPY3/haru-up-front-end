//
//  GradientBackgroundView.swift
//  HaruUp
//
//  Created by 조영현 on 12/24/25.
//

import UIKit

final class GradientBackgroundView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // MARK: - Init
    
    /// 다양한 옵션을 받아 그라데이션 뷰를 생성합니다.
    /// - Parameters:
    ///   - startColor: 그라데이션 시작 색상
    ///   - endColor: 그라데이션 끝 색상
    ///   - locations: 색상이 변하는 위치 비율 (기본값: [0.0, 1.0])
    ///   - startPoint: 그라데이션 시작점 좌표 (0.0 ~ 1.0, 기본값: 상단 중앙)
    ///   - endPoint: 그라데이션 끝점 좌표 (0.0 ~ 1.0, 기본값: 하단 중앙)
    init(
        startColor: UIColor,
        endColor: UIColor,
        locations: [NSNumber] = [0.0, 1.0],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), // 기본값: 수직 방향
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)
    ) {
        super.init(frame: .zero)
        setupGradient(
            start: startColor,
            end: endColor,
            locations: locations,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupGradient(
        start: UIColor,
        end: UIColor,
        locations: [NSNumber],
        startPoint: CGPoint,
        endPoint: CGPoint
    ) {
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        // 색상, 위치, 방향(포인트) 적용
        gradientLayer.colors = [start.cgColor, end.cgColor]
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
}
