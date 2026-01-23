//
//  HistoryModel.swift
//  HaruUp
//
//  Created by 조영현 on 1/14/26.
//

import Foundation

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

struct DailyMission {
    let targetDate: String
    let completedCount: Int
    
    var day: Int? {
        let components = targetDate.split(separator: "-")
        guard components.count == 3,
              let day = Int(components[2]) else { return nil }
        return day
    }
    
    var hasCompleted: Bool {
        completedCount > 0
    }
}

// MARK: - Calendar 데이터 모델
struct CalendarDay {
    let day: Int
    let month: Int  // 해당 날짜의 실제 월
    let year: Int   // 해당 날짜의 실제 연도
    let isCurrentMonth: Bool
    
    /// 이전달로 이동해야 하는지
    var isPreviousMonth: Bool {
        return !isCurrentMonth && day > 15
    }
    
    /// 다음달로 이동해야 하는지
    var isNextMonth: Bool {
        return !isCurrentMonth && day < 15
    }
}

// MARK: - DTO → Domain 변환
extension DailyMission {
    init(from dto: MemberMission.HistoryDTO) {
        self.targetDate = dto.targetDate
        self.completedCount = dto.completedCount
    }
}

extension Array where Element == MemberMission.HistoryDTO {
    func toDomain() -> [DailyMission] {
        self.map { DailyMission(from: $0) }
    }
}
