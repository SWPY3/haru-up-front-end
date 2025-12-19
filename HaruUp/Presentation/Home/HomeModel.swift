//
//  HomeModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

struct Mission: Hashable {
    let title: String
    let difficulty: MissionDifficultyModel
    let exp: Int
}

enum TodayMissionRow: Hashable {
    case empty
    case mission(Mission)
    case add
}
