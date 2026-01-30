//
//  GrowthChartScaleCalculator.swift
//  HaruUp
//
//  Created by 조영현 on 1/30/26.
//

import UIKit

struct GrowthChartScale {
    let maxValue: Int           // Y축 최대값
    let gridValues: [Int]       // 그리드 라인 값들 (항상 5개)
    let dataMaxValue: Int       // 실제 데이터 최대값
    
    /// 말풍선 공간을 확보한 Y축 스케일 계산 (그리드 5개 고정)
    static func calculate(from data: [(String, Int)]) -> GrowthChartScale {
        let values = data.map { $0.1 }
        let dataMax = values.max() ?? 0
        
        let (maxValue, gridValues) = determineScale(for: dataMax)
        
        return GrowthChartScale(
            maxValue: maxValue,
            gridValues: gridValues,
            dataMaxValue: dataMax
        )
    }
    
    private static func determineScale(for dataMax: Int) -> (maxValue: Int, gridValues: [Int]) {
        // 데이터가 0인 경우
        if dataMax <= 0 {
            return (maxValue: 4, gridValues: [0, 1, 2, 3, 4])
        }
        
        // 데이터 최대값의 약 1.35배를 목표로 (말풍선 공간 확보)
        let targetMax = Double(dataMax) * 1.25
        
        // 5개 그리드를 위한 간격 계산 (4등분)
        let rawInterval = targetMax / 4.0
        
        // "nice" 간격으로 올림
        let interval = niceInterval(rawInterval)
        
        // 최종 maxValue (interval × 4)
        let maxValue = interval * 4
        
        // 그리드 값 생성 (항상 5개: 0, 1/4, 2/4, 3/4, 4/4)
        let gridValues = [0, interval, interval * 2, interval * 3, interval * 4]
        
        return (maxValue: maxValue, gridValues: gridValues)
    }
    
    /// 깔끔한 간격 값으로 올림
    private static func niceInterval(_ value: Double) -> Int {
        let niceNumbers = [1, 2, 5, 10, 15, 20, 25, 50, 100]
        
        for nice in niceNumbers {
            if Double(nice) >= value {
                return nice
            }
        }
        
        // 100 이상인 경우 50 단위로 올림
        return Int(ceil(value / 50.0)) * 50
    }
}
