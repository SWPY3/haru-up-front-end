//
//  GrowthChartSwiftUIView.swift
//  HaruUp
//
//  Created by 조영현 on 1/16/26.
//

import SwiftUI
import Charts

// MARK: - SwiftUI Chart View
@available(iOS 16.0, *)
struct GrowthChartSwiftUIView: View {
    let data: [GrowthChartDataPoint]
    let highlightLast: Bool
    
    var body: some View {
        Chart {
            // 영역 채우기 (그라디언트)
            ForEach(data) { point in
                AreaMark(
                    x: .value("Month", point.month),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom) // 부드러운 곡선
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.calendarGradient.opacity(1.0),
                            Color.calendarGradient.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // 라인
            ForEach(data) { point in
                LineMark(
                    x: .value("Month", point.month),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom) // 부드러운 곡선
                .foregroundStyle(Color.primaryBlue600)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            
            // 마지막 포인트 강조
            if highlightLast, let lastPoint = data.last {
                // 점선 (세로)
                RuleMark(
                    x: .value("Month", lastPoint.month),
                    yStart: .value("Start", 0),           // 바닥 (Y축 최소값)
                    yEnd: .value("End", lastPoint.value)  // 포인트 위치까지
                )
                .foregroundStyle(Color.primaryBlue500)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                
                // 포인트
                PointMark(
                    x: .value("Month", lastPoint.month),
                    y: .value("Value", lastPoint.value)
                )
                .symbolSize(0) // 기본 심볼 숨김
                .annotation(position: .overlay) {
                    // 글로우 + 원
                    ZStack {
                        Circle()
                            .fill(Color.calendarPointShadow)
                            .frame(width: 30, height: 30)
                        
                        Circle()
//                            .stroke(Color.white, lineWidth: 2)
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                        
                        Circle()
                            .fill(Color.primaryBlue600)
                            .frame(width: 10, height: 10)
                    }
                }
                .annotation(position: .top, spacing: 15) {
                    CalendarBubbleView(value: lastPoint.value)
                }
            }
        }
        // TODO: 값을 받아올 때 0~40인 경우 30~40에는 해당되지 않게 적용
        .chartYScale(domain: 0...40)
        // Y축을 왼쪽(leading)으로 이동
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 10, 20, 30, 40]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.neutral10)
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(Font(Typography.yText.font))
                            .foregroundStyle(Color.neutral500)
                            .padding(.trailing, 13)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let month = value.as(String.self) {
                        Text(month)
                            .font(Font(Typography.xText.font))
                            .foregroundStyle(Color.neutral1000)
                    }
                }
            }
        }
        .padding(.top, 16)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
        }
    }
}

// MARK: - Bubble Badge View
@available(iOS 16.0, *)
struct CalendarBubbleView: View {
    let value: Int
    
    private let arrowHeight: CGFloat = 10
    
    var body: some View {
        Text("\(value)일")
            .font(Font(Typography.level.font))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .padding(.bottom, arrowHeight)  // 화살표 높이만큼 추가 패딩
            .background(
                BubbleShape()
                    .fill(Color.primaryBlue700)
            )
    }
}

// MARK: - Bubble Shape (말풍선)
struct BubbleShape: Shape {
    var arrowHeight: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 8
        let arrowWidth: CGFloat = 14
        let arrowTipRadius: CGFloat = 2 // 화살표 끝 둥글기
        
        // 말풍선 본체 영역 (화살표 높이 제외)
        // rect.minX, minY 등을 사용하여 좌표 기준을 명확히 함
        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - arrowHeight
        )
        
        // 그리기 시작: 왼쪽 위 라운드 시작점
        path.move(to: CGPoint(x: bubbleRect.minX, y: bubbleRect.minY + cornerRadius))
        
        // 1. 왼쪽 위 모서리 (Top-Left)
        path.addArc(
            center: CGPoint(x: bubbleRect.minX + cornerRadius, y: bubbleRect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // 2. 오른쪽 위 모서리 (Top-Right)
        path.addArc(
            center: CGPoint(x: bubbleRect.maxX - cornerRadius, y: bubbleRect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // 3. 오른쪽 아래 모서리 (Bottom-Right)
        path.addArc(
            center: CGPoint(x: bubbleRect.maxX - cornerRadius, y: bubbleRect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // 4. 아래쪽 라인 ~ 화살표 시작점
        path.addLine(to: CGPoint(x: rect.midX + arrowWidth / 2, y: bubbleRect.maxY))
        
        // 5. 화살표 그리기 (V자 모양 + 끝부분 둥글게)
        // 화살표 오른쪽 변 타고 내려감
        path.addLine(to: CGPoint(x: rect.midX + arrowTipRadius, y: rect.maxY - arrowTipRadius))
        
        // 화살표 끝 둥글리기 (QuadCurve 사용)
        path.addQuadCurve(
            to: CGPoint(x: rect.midX - arrowTipRadius, y: rect.maxY - arrowTipRadius),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        
        // 화살표 왼쪽 변 타고 올라옴
        path.addLine(to: CGPoint(x: rect.midX - arrowWidth / 2, y: bubbleRect.maxY))
        
        // 6. 왼쪽 아래 모서리 (Bottom-Left)
        path.addArc(
            center: CGPoint(x: bubbleRect.minX + cornerRadius, y: bubbleRect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // 경로 닫기 (자동으로 시작점과 연결됨)
        path.closeSubpath()
        
        return path
    }
}
