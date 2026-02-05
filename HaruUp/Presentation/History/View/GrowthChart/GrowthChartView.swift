//
//  GrowthChartView.swift
//  HaruUp
//
//  Created by 조영현 on 1/15/26.
//

import SwiftUI

// MARK: - UIKit Wrapper
@available(iOS 16.0, *)
class GrowthChartView: UIView {
    
    private var hostingController: UIHostingController<GrowthChartSwiftUIView>?
    private var data: [GrowthChartDataPoint] = []
    private var highlightLast: Bool = false
    private var scale: GrowthChartScale = GrowthChartScale(maxValue: 40, gridValues: [0, 10, 20, 30, 40], dataMaxValue: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    func configure(with data: [(String, Int)], highlightLast: Bool = false) {
        self.data = data.map { GrowthChartDataPoint(month: $0.0, value: $0.1) }
        self.highlightLast = highlightLast
        
        self.scale = GrowthChartScale.calculate(from: data)
        
        updateChart()
    }
    
    private func updateChart() {
        // 기존 호스팅 컨트롤러 제거
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        
        let chartView = GrowthChartSwiftUIView(
            data: data,
            highlightLast: highlightLast,
            scale: scale
        )
        let hosting = UIHostingController(rootView: chartView)
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hosting.view)
        
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        hostingController = hosting
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hostingController?.view.frame = bounds
    }
}
