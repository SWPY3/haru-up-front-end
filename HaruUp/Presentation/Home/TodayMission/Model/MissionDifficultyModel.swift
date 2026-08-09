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
        case .veryHigh, .high: return "고급"
        case .mediumHigh, .medium: return "중급"
        case .low: return "초급"
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

    /// 백엔드 difficulty 값(1~5)을 iOS 모델로 변환
    /// 챗봇 미션은 1/2/3 스케일 사용 → 3은 "고급"으로 처리
    static func from(difficulty: Int) -> MissionDifficultyModel {
        switch difficulty {
        case 1:  return .low
        case 2:  return .medium
        case 3:  return .high
        case 4:  return .high
        case 5:  return .veryHigh
        default: return .low
        }
    }
}

/// AI 추천미션 리스트 상단의 난이도 필터
enum MissionDifficultyFilter: CaseIterable {
    case all
    case beginner
    case intermediate
    case advanced

    var title: String {
        switch self {
        case .all: return "전체"
        case .beginner: return "초급"
        case .intermediate: return "중급"
        case .advanced: return "고급"
        }
    }

    func matches(_ difficulty: MissionDifficultyModel) -> Bool {
        switch self {
        case .all: return true
        case .beginner: return difficulty == .low
        case .intermediate: return difficulty == .medium || difficulty == .mediumHigh
        case .advanced: return difficulty == .high || difficulty == .veryHigh
        }
    }
}
