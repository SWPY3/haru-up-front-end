//
//  MissionToolTipView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class MissionToolTipView: UIView {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "오늘의 미션은 자정이 지나면 사라져요")
        label.textColor = .white
        label.numberOfLines = 1 // 한줄로 고정
        
        return label
    }()
    
    private let triangleView = TriangleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        configureContainer()
        configureLabel()
        configureTriangle()
    }
    
    private func configureContainer() {
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func configureLabel() {
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    private func configureTriangle() {
        self.addSubview(triangleView)
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            triangleView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            triangleView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            triangleView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            triangleView.heightAnchor.constraint(equalToConstant: 14),
            triangleView.widthAnchor.constraint(equalToConstant: 18)
        ])
    }
}

fileprivate class TriangleView: UIView {

    private let color: UIColor
    private let cornerRadius: CGFloat

    // init에 radius 파라미터 추가 (기본값 1.0 설정)
    init(color: UIColor = .black, radius: CGFloat = 2.0) {
        self.color = color
        self.cornerRadius = radius
        super.init(frame: .zero)
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = CGMutablePath()
        
        let topLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x: rect.width, y: 0)
        let bottomTip = CGPoint(x: rect.width / 2, y: rect.height)
        
        path.move(to: CGPoint(x: rect.width / 2, y: 0))
        // 오른쪽 위 코너 (현재 위치 -> topRight -> bottomTip)
        path.addArc(tangent1End: topRight, tangent2End: bottomTip, radius: cornerRadius)
        // 아래쪽 꼭짓점 (현재 위치 -> bottomTip -> topLeft)
        path.addArc(tangent1End: bottomTip, tangent2End: topLeft, radius: cornerRadius)
        // 왼쪽 위 코너 (현재 위치 -> topLeft -> topRight)
        path.addArc(tangent1End: topLeft, tangent2End: topRight, radius: cornerRadius)
        path.closeSubpath()
        
        let bezierPath = UIBezierPath(cgPath: path)
        color.setFill()
        bezierPath.fill()
    }
}
