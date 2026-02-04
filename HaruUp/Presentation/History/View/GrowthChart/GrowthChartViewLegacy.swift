//
//  GrowthChartViewLegacy.swift
//  HaruUp
//
//  Created by 조영현 on 1/16/26.
//

import UIKit

// MARK: - iOS 15 이하 지원용 Fallback
class GrowthChartViewLegacy: UIView {
    
    private var data: [(month: String, value: Int)] = []
    private var highlightLast: Bool = false
    private var scale: GrowthChartScale = GrowthChartScale(maxValue: 40, gridValues: [0, 10, 20, 30, 40], dataMaxValue: 0)
    
    func configure(with data: [(String, Int)], highlightLast: Bool = false) {
        self.data = data.map { (month: $0.0, value: $0.1) }
        self.highlightLast = highlightLast
        self.scale = GrowthChartScale.calculate(from: data)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard data.count > 1 else { return }
        
        // 상단 여백 늘림 (말풍선 공간)
        let padding = UIEdgeInsets(top: 60, left: 20, bottom: 30, right: 20)
        let graphRect = CGRect(
            x: padding.left,
            y: padding.top,
            width: rect.width - padding.left - padding.right,
            height: rect.height - padding.top - padding.bottom
        )
        
        let maxValue = CGFloat(scale.maxValue)
        let points = calculatePoints(in: graphRect, maxValue: maxValue)
        
        // Y축 그리드 제거 (drawGridLines 호출 안 함)
        drawGradientFill(points: points, graphRect: graphRect)
        drawCurvedLine(points: points)
        drawMonthLabels(points: points, graphRect: graphRect)
        
        // 모든 포인트에 라벨과 원 표시
        drawAllPoints(points: points, graphRect: graphRect)
    }
    
    private func calculatePoints(in graphRect: CGRect, maxValue: CGFloat) -> [CGPoint] {
        return data.enumerated().map { index, item in
            let x = graphRect.minX + (CGFloat(index) / CGFloat(data.count - 1)) * graphRect.width
            let y = graphRect.maxY - (CGFloat(item.value) / maxValue * graphRect.height)
            return CGPoint(x: x, y: y)
        }
    }
    
    private func drawGradientFill(points: [CGPoint], graphRect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let firstPoint = points.first,
              let lastPoint = points.last else { return }
        
        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: firstPoint.x, y: graphRect.maxY))
        
        addLinearPath(to: fillPath, points: points)
        
        fillPath.addLine(to: CGPoint(x: lastPoint.x, y: graphRect.maxY))
        fillPath.close()
        
        context.saveGState()
        fillPath.addClip()
        
        let colors = [
            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.0).cgColor
        ]
        
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1]) {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: graphRect.minY), end: CGPoint(x: 0, y: graphRect.maxY), options: [])
        }
        context.restoreGState()
    }
    
    private func drawCurvedLine(points: [CGPoint]) {
        let linePath = UIBezierPath()
        addLinearPath(to: linePath, points: points, moveToFirst: true)
        
        UIColor.systemBlue.setStroke()
        linePath.lineWidth = 2.5
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        linePath.stroke()
    }
    
    private func addLinearPath(to path: UIBezierPath, points: [CGPoint], moveToFirst: Bool = false) {
        guard let firstPoint = points.first else { return }
        
        if moveToFirst {
            path.move(to: firstPoint)
        } else {
            path.addLine(to: firstPoint)
        }
        
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
    }
    
    
    private func addCatmullRomCurve(to path: UIBezierPath, points: [CGPoint], moveToFirst: Bool = false) {
        guard points.count > 1 else { return }
        
        if moveToFirst {
            path.move(to: points[0])
        } else {
            path.addLine(to: points[0])
        }
        
        for i in 0..<points.count - 1 {
            let p0 = i == 0 ? points[0] : points[i - 1]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i + 2 < points.count ? points[i + 2] : p2
            
            let tension: CGFloat = 0.5
            
            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6 * tension,
                y: p1.y + (p2.y - p0.y) / 6 * tension
            )
            
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6 * tension,
                y: p2.y - (p3.y - p1.y) / 6 * tension
            )
            
            path.addCurve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
        }
    }
    
    private func drawMonthLabels(points: [CGPoint], graphRect: CGRect) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label
        ]
        
        for (index, point) in points.enumerated() {
            let label = data[index].month
            let labelSize = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: point.x - labelSize.width / 2, y: graphRect.maxY + 8), withAttributes: attributes)
        }
    }
    
    // MARK: - 모든 포인트 그리기
    private func drawAllPoints(points: [CGPoint], graphRect: CGRect) {
        for (index, point) in points.enumerated() {
            let isLast = index == points.count - 1 && highlightLast
            let value = data[index].value
            
            if isLast {
                // 마지막 포인트: 점선 + 글로우 + 말풍선
                drawDashedLine(at: point, graphRect: graphRect)
                drawHighlightPoint(at: point)
                drawBadge(at: point, value: value)
            } else {
                // 일반 포인트: 원 + 텍스트 라벨
                drawNormalPoint(at: point)
                drawTextLabel(at: point, value: value)
            }
        }
    }
    
    // MARK: - 일반 포인트
    private func drawNormalPoint(at point: CGPoint) {
        // 흰색 원
        let circleRect = CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        UIColor.white.setFill()
        circlePath.fill()
        
        // 파란색 내부 원
        let innerRect = CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)
        let innerPath = UIBezierPath(ovalIn: innerRect)
        UIColor.systemBlue.setFill()
        innerPath.fill()
    }
    
    // MARK: - 텍스트 라벨 (일반 포인트용)
    private func drawTextLabel(at point: CGPoint, value: Int) {
        let text = "\(value)일"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textPoint = CGPoint(
            x: point.x - textSize.width / 2,
            y: point.y - textSize.height - 12
        )
        text.draw(at: textPoint, withAttributes: attributes)
    }
    
    // MARK: - 마지막 포인트 (기존 유지)
    private func drawDashedLine(at point: CGPoint, graphRect: CGRect) {
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: point.x, y: point.y))
        dashPath.addLine(to: CGPoint(x: point.x, y: graphRect.maxY))
        
        UIColor.systemBlue.withAlphaComponent(0.3).setStroke()
        dashPath.lineWidth = 1
        dashPath.setLineDash([4, 4], count: 2, phase: 0)
        dashPath.stroke()
    }
    
    private func drawHighlightPoint(at point: CGPoint) {
        // 글로우 효과
        let glowRect = CGRect(x: point.x - 15, y: point.y - 15, width: 30, height: 30)
        let glowPath = UIBezierPath(ovalIn: glowRect)
        UIColor.systemBlue.withAlphaComponent(0.15).setFill()
        glowPath.fill()
        
        // 흰색 원
        let circleRect = CGRect(x: point.x - 7, y: point.y - 7, width: 14, height: 14)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        UIColor.white.setFill()
        circlePath.fill()
        
        // 파란색 내부 원
        let innerRect = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
        let innerPath = UIBezierPath(ovalIn: innerRect)
        UIColor.systemBlue.setFill()
        innerPath.fill()
    }
    
    private func drawBadge(at point: CGPoint, value: Int) {
        let text = "\(value)일"
        let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let badgePadding: CGFloat = 12
        let badgeHeight: CGFloat = textSize.height + 12
        let badgeWidth: CGFloat = textSize.width + badgePadding * 2
        let arrowHeight: CGFloat = 6
        
        let badgeRect = CGRect(
            x: point.x - badgeWidth / 2,
            y: point.y - badgeHeight - arrowHeight - 12,
            width: badgeWidth,
            height: badgeHeight
        )
        
        // 말풍선
        let bubblePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: badgeHeight / 2)
        UIColor.systemBlue.setFill()
        bubblePath.fill()
        
        // 화살표
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: point.x - 5, y: badgeRect.maxY))
        arrowPath.addLine(to: CGPoint(x: point.x, y: badgeRect.maxY + arrowHeight))
        arrowPath.addLine(to: CGPoint(x: point.x + 5, y: badgeRect.maxY))
        arrowPath.close()
        UIColor.systemBlue.setFill()
        arrowPath.fill()
        
        // 텍스트
        text.draw(at: CGPoint(x: badgeRect.midX - textSize.width / 2, y: badgeRect.midY - textSize.height / 2), withAttributes: attributes)
    }
}
