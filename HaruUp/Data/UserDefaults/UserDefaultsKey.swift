//
//  UserDefaultsKey.swift
//  HaruUp
//
//  Created by 조영현 on 12/26/25.
//

enum UserDefaultsKey {
    /// 미션을 선택한 날짜를 저장.
    static let todayMissionSelectedDate = "todayMissionSelectedDate"
    /// 사용자가 확인한 관심사의 ID
    static let selectedMemberInterestId = "selectedMemberInterestId"
    /// 챗봇 목표 기반 미션 플로우 사용 여부
    static let usesChatbotGoalMissions = "usesChatbotGoalMissions"
    /// 오늘의 미션 인트로를 마지막으로 본 날짜
    static let lastIntroShownDate = "lastIntroShownDate"
}
