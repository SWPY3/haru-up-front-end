//
//  MissionDifficultyModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

enum MissionDifficultyModel: Int, CaseIterable {
    case veryHigh = 5
    case high = 4
    case mediumHigh = 3
    case medium = 2
    case low = 1
    
    var title: String {
        switch self {
        case .veryHigh: return "최상"
        case .high: return "상"
        case .mediumHigh: return "중상"
        case .medium: return "중"
        case .low: return "하"
        }
    }
    
    var color: UIColor {
        switch self {
        case .veryHigh: return .secondaryRed100
        case .high: return .secondaryRed100
        case .mediumHigh: return .primaryBlue50
        case .medium: return .primaryBlue50
        case .low: return .secondaryMint100
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .veryHigh: return .secondaryRed200
        case .high: return .secondaryRed200
        case .mediumHigh: return .primaryBlue700
        case .medium: return .primaryBlue700
        case .low: return .secondaryMint200
        }
    }
}
