//
//  MissionDayBottomModel.swift
//  HaruUp
//
//  Created by 조영현 on 1/2/26.
//

import UIKit

enum MissionChallengeStatus {
    case completed
    case failed
    case none
    
    var iconImage: UIImage? {
        switch self {
        case .completed: return .iconChallengeSuccess
        case .failed:    return .iconChallengeFail
        case .none:      return .iconChallengeNone
        }
    }
}

struct DailyMissionData {
    let dayString: String
    let status: MissionChallengeStatus
}
