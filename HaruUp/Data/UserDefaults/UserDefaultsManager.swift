//
//  UserDefaultsManager.swift
//  HaruUp
//
//  Created by 조영현 on 12/31/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager() // 싱글톤으로 간단히 접근하거나, DI 컨테이너를 쓴다면 제거
    private let defaults = UserDefaults.standard
    
    var selectedMemberInterestId: Int? {
        get {
            let value = defaults.integer(forKey: UserDefaultsKey.selectedMemberInterestId)
            return defaults.object(forKey: UserDefaultsKey.selectedMemberInterestId) == nil ? nil : value
        }
        set {
            if let newValue {
                defaults.set(newValue, forKey: UserDefaultsKey.selectedMemberInterestId)
            } else {
                defaults.removeObject(forKey: UserDefaultsKey.selectedMemberInterestId)
            }
        }
    }
    
    // MARK: - 미션 관련
    /// 오늘 미션을 선택했는지 확인
    var isTodayMissionSelected: Bool {
        let today = todayString()
        let saved = defaults.string(forKey: UserDefaultsKey.todayMissionSelectedDate)
        return saved == today
    }
    
    /// 오늘 미션 선택 플로우를 보여줘야 하는지
    var needShowTodayMissionFlow: Bool {
        return !isTodayMissionSelected
    }
    
    /// 오늘 미션 선택 완료 표시
    func markTodayMissionSelected() {
        let today = todayString()
        defaults.set(today, forKey: UserDefaultsKey.todayMissionSelectedDate)
    }
    
    /// 미션 선택 날짜 초기화
    func clearTodayMissionSelectedDate() {
        defaults.removeObject(forKey: UserDefaultsKey.todayMissionSelectedDate)
    }
    
    // MARK: - Helper
    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
