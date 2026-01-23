//
//  GrowthChartDataPoint.swift
//  HaruUp
//
//  Created by 조영현 on 1/16/26.
//

import SwiftUI

struct GrowthChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let value: Int
}
