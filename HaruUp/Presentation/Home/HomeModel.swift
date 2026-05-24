//
//  HomeModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

struct HomeMemberInfo {
    let characterId: Int
    let level: Int
    let nickname: String
    let totalExp: Int
    let maxExp: Int
    let currentExp: Int
    let interest: String
    
    static let empty = Self(characterId: 0, level: 0, nickname: "", totalExp: 0, maxExp: 0, currentExp: 0, interest: "")
}

struct Mission: Hashable {
    let id: Int
    let title: String
    let description: String?
    let difficulty: MissionDifficultyModel
    let exp: Int
    let isCompleted: Bool
}

enum TodayMissionRow: Hashable {
    case empty
    case mission(Mission)
    case add
}

/// 캐릭터 Level별 텍스트
enum CharacterLevel: Int {
    case challenger = 1 // 도전하는
    case growing    = 2 // 성장하는
    case steady     = 3 // 꾸준한
    case proud      = 4 // 우쭐한
    
    var title: String {
        switch self {
        case .challenger: return "도전하는"
        case .growing:    return "성장하는"
        case .steady:     return "꾸준한"
        case .proud:      return "우쭐한"
        }
    }
}
