//
//  MainTab.swift
//  HaruUp
//
//  Created by 조영현 on 12/16/25.
//

import UIKit

enum MainTab: Int, CaseIterable {
    //    case home, history, chart, mypage
    case home, chart, mypage
    
    var title: String {
        switch self {
        case .home: return "홈"
            //        case .history: return "나의 기록"
        case .chart: return "차트"
        case .mypage: return "마이페이지"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home: return .iconTabHomeUnselected
            //        case .history: return .iconTabHistoryUnselected
        case .chart: return .iconTabChartUnselected
        case .mypage: return .iconTabMypageUnselected
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .home: return .iconTabHomeSelected
            //        case .history: return .iconTabHistorySelected
        case .chart: return .iconTabChartSelected
        case .mypage: return .iconTabMypageSelected
        }
    }
}
