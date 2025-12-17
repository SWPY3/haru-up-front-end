//
//  SpeechBubbleView.swift
//  HaruUp
//
//  Created by 조영현 on 12/17/25.
//

import UIKit

final class SpeechBubbleView: UIView {

    private let contentInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
    private let cornerRadius: CGFloat = 22
    let tailSize = CGSize(width: 12, height: 8)
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let tailHeight = tailSize.height
        let tailWidth = tailSize.width
        
        let rect = bounds.insetBy(dx: 0, dy: 0)
        let bubbleRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailHeight)
        let midX = bubbleRect.midX
        
        let path = UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerRadius)

        let startPoint = CGPoint(x: midX - tailWidth/2, y: bubbleRect.maxY)
        let tipPoint = CGPoint(x: midX, y: bubbleRect.maxY + tailHeight)
        let endPoint = CGPoint(x: midX + tailWidth/2, y: bubbleRect.maxY)
        
        let tailPath = CGMutablePath() // 라운딩 처리
        tailPath.move(to: startPoint)
        
        tailPath.addArc(tangent1End: tipPoint, tangent2End: endPoint, radius: 2) // radius 2
        
        tailPath.addLine(to: endPoint)
        tailPath.closeSubpath()
        
        path.append(UIBezierPath(cgPath: tailPath))

        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        
        setupShapeLayer()
        configureLabel()
    }
    
    private func setupShapeLayer() {
        shapeLayer.fillColor = UIColor.white.cgColor
        
        shapeLayer.shadowColor = UIColor.bubbleShadow.cgColor
        shapeLayer.shadowOpacity = 1.0
        shapeLayer.shadowRadius = 10
        
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    private func configureLabel() {
        self.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInsets.top),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInsets.left),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInsets.right),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(contentInsets.bottom + tailSize.height))
        ])
    }

    func setText(_ text: String) {
        textLabel.setStyle(Typography.body3, text: text)
    }
}
