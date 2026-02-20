//
//  AnalyticsManager.swift
//  HaruUp
//
//  Created by 조영현 on 2/20/26.
//

import Foundation
import AmplitudeSwift

enum AppEvent: String {
    case refreshMissionListTapped = "Refresh Mission List Tapped"
}

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}

    // 이벤트와 세부 속성(Properties)을 함께 전송하는 메서드
    func track(event: AppEvent, properties: [String: Any]? = nil) {
        AppDelegate.amplitude?.track(eventType: event.rawValue, eventProperties: properties)
    }
}
