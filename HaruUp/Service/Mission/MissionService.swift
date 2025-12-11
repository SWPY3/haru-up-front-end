//
//  MissionService.swift
//  HaruUp
//
//  Created by 조영현 on 12/11/25.
//

import Foundation
import RxSwift
import Alamofire

protocol MissionServiceType {
    // Home에서 미션 선택창을 띄워야하는지 여부
    func needShowTodayMissionFlow() -> Single<Bool>
}

final class MissionService: MissionServiceType {
    private let defaults = UserDefaults.standard
}

// MARK: UserDefaults - 미션 선택 여부
extension MissionService {
    private enum Keys {
        static let todayMissionSelectedDate = "todayMissionSelectedDate"
    }
    
    func needShowTodayMissionFlow() -> Single<Bool> {
        let today = Self.todayString()
        let saved = defaults.string(forKey: Keys.todayMissionSelectedDate)
        print("today: \(today)")
        print("saved: \(saved)")
        let needShow = (saved != today)
        return .just(needShow)
    }
    
    func markTodayMissionSelected() {
        let today = Self.todayString()
        defaults.set(today, forKey: Keys.todayMissionSelectedDate)
    }
    
    private static func todayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
