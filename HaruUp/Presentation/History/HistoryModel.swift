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
    
    struct GrowthData {
        let targetMonth: String
        let attendanceCount: Int
        
        /// "2025-08" → "8월"
        var monthLabel: String {
            let components = targetMonth.split(separator: "-")
            guard components.count == 2,
                  let month = Int(components[1]) else { return "" }
            return "\(month)월"
        }
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

// MARK: - Calendar에 표시할 데이터 (월별 통계)
struct MonthlyMissionSummary {
    let dailyMissions: [DailyMission]
    let totalMissionCount: Int
    let totalCompletedDays: Int
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
    init(from dto: MemberMission.MissionCountDTO) {
        self.targetDate = dto.targetDate
        self.completedCount = dto.completedCount
    }
}

extension MemberMission.HistoryDTO {
    func toDomain() -> MonthlyMissionSummary {
        let dailyMissions = missionCounts.map { DailyMission(from: $0) }
        return MonthlyMissionSummary(
            dailyMissions: dailyMissions,
            totalMissionCount: totalMissionCount,
            totalCompletedDays: totalCompletedDays
        )
    }
}

extension MemberMission.AttendanceDate {
    func toDomain() -> HistoryModel.GrowthData {
        return HistoryModel.GrowthData(
            targetMonth: targetMonth,
            attendanceCount: attendanceCount
        )
    }
}

extension MemberMission.GrowthDataDTO {
    func toDomain() -> [HistoryModel.GrowthData] {
        return attendanceDates.map { $0.toDomain() }
    }
}
