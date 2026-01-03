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
    let currentExp: Int
    let interest: String
    
    static let empty = Self(characterId: 0, level: 0, nickname: "", totalExp: 0, currentExp: 0, interest: "")
}

struct Mission: Hashable {
    let id: Int
    let title: String
    let difficulty: MissionDifficultyModel
    let exp: Int
    let isCompleted: Bool
}

enum TodayMissionRow: Hashable {
    case empty
    case mission(Mission)
    case add
}
