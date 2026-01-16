//
//  HistoryModel.swift
//  HaruUp
//
//  Created by 조영현 on 1/14/26.
//

struct HistoryModel {
    struct Mission {
        let title: String
        let difficulty: MissionDifficultyModel
        let exp: Int
    }

    struct CalendarData {
        let attendanceDays: Int
        let completedMissions: Int
        let dailyMissions: [Int: [Mission]]
        let specialDays: [Int]
    }
}
