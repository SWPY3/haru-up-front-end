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
    
    // MARK: - 관심사 관련
    // 사용자가 선택한 관심사
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
    
    /// 선택된 관심사 초기화
    func clearSelectedMemberInterestId() {
        selectedMemberInterestId = nil
    }
}
