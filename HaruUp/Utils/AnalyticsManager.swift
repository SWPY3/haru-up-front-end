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
