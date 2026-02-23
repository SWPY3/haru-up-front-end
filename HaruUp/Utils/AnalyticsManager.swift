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
        case startTapped = "[MissionStart] Start Recommendation Tapped"
    }
    
    // MARK: - 미션 추천 목록 화면 (Mission List)
    enum MissionList: String {
        case closeTapped = "[MissionList] Close Tapped"
        case refreshTapped = "[MissionList] Refresh Tapped"
        case infoIconTapped = "[MissionList] Info Icon Tapped"
        case completeTapped = "[MissionList] Complete Tapped"
        case selectedMissionDifficulty = "[MissionList] Selected Mission Difficulty"
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
