//
//  GrowthChartViewFactory.swift
//  HaruUp
//
//  Created by 조영현 on 1/16/26.
//

import UIKit

// MARK: - Factory for version compatibility
class GrowthChartViewFactory {
    static func create() -> UIView {
        if #available(iOS 16.0, *) {
            return GrowthChartView()
        } else {
            return GrowthChartViewLegacy()
        }
    }
    
    static func configure(_ view: UIView, with data: [(String, Int)], highlightLast: Bool = false) {
        if #available(iOS 16.0, *), let chartView = view as? GrowthChartView {
            chartView.configure(with: data, highlightLast: highlightLast)
        } else if let legacyView = view as? GrowthChartViewLegacy {
            legacyView.configure(with: data, highlightLast: highlightLast)
        }
    }
}
