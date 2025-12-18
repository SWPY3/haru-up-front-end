//
//  HomeModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

struct Mission: Hashable {
    let id: Int
    let title: String
    let isCompleted: Bool
}

enum TodayMissionRow: Hashable {
    case empty
    case mission(Mission)
    case add
}
