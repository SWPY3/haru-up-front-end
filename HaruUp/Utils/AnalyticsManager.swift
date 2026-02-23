//
//  AnalyticsManager.swift
//  HaruUp
//
//  Created by 조영현 on 2/20/26.
//

import Foundation
import AmplitudeSwift

enum AppEvent {
    
    // MARK: - 미션 시작 화면 (Mission Start)
    enum MissionStart: String {
        case startTapped = "[MissionStart] Start Recommendation Tapped" // 미션 추천 시작 버튼
    }
    
    // MARK: - 미션 추천 목록 화면 (Mission List)
    enum MissionList: String {
        case closeTapped = "[MissionList] Close Tapped"             // 종료 버튼
        case refreshTapped = "[MissionList] Refresh Tapped"         // 다른 추천 버튼
        case infoIconTapped = "[MissionList] Info Icon Tapped"      // 다른 추천 info Icon
        case completeTapped = "[MissionList] Complete Tapped"       // 미션 선택 완료 버튼
        case selectedMissionDifficulty = "[MissionList] Selected Mission Difficulty" // 선택한 난이도들
    }
    
    // MARK: - 탭 바 (Tab Bar)
    enum Tab: String {
        case homeTapped = "[Tab] Home Tapped"
        case recordTapped = "[Tab] Record Tapped"
        case chartTapped = "[Tab] Chart Tapped"
        case myPageTapped = "[Tab] MyPage Tapped"
    }
    
    // MARK: - 홈 화면 (Home)
    enum Home: String {
        case streakButtonTapped = "[Home] Streak Button Tapped"         // 연속 달성일 버튼
        case characterTapped = "[Home] Character Tapped"               // 캐릭터
        case speechBubbleTapped = "[Home] Speech Bubble Tapped"         // 말풍선
        case todayMissionInfoTapped = "[Home] Today Mission Info Tapped" // 오늘의 미션 info
        case addMissionTapped = "[Home] Add Mission Tapped"             // 미션 추가하기
        case missionResultTapped = "[Home] Mission Result Tapped"       // 미션 수행 결과 버튼
        case completeMissionTapped = "[Home] Complete Mission Tapped"   // (바텀시트) 미션 완료
        case deleteMissionTapped = "[Home] Delete Mission Tapped"       // (바텀시트) 미션 삭제
        case confirmDeleteTapped = "[Home] Confirm Delete Tapped"       // (삭제 바텀시트) 최종 삭제
        case cancelDeleteTapped = "[Home] Cancel Delete Tapped"         // (삭제 바텀시트) 취소
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
    
    // RawRepresentable을 사용하여 String을 rawValue로 갖는 어떤 enum이든 받을 수 있게 만듦
    func track<T: RawRepresentable>(event: T, properties: [String: Any]? = nil) where T.RawValue == String {
        // 실제 Amplitude 전송 코드
        AppDelegate.amplitude?.track(eventType: event.rawValue, eventProperties: properties)
    }
}
