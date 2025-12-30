//
//  Interest.swift
//  HaruUp
//
//  Created by 하다현 on 12/26/25.
//

import Foundation

struct InterestResponse: Codable {
    let interests: [InterestData]
    let totalCount: Int
}



struct InterestData: Codable, Sendable {
    let id: Int
    let name: String
    var parentId: Int? = nil
    var directFullPath: [String]? = nil
}


struct Interest {
    let id: Int
    let icon: String
    let title: String
    

    init(from data: InterestData) {
        self.id = data.id
        self.title = data.name
        self.icon = Interest.iconForInterest(name: data.name)
    }
    
    
    static func iconForInterest(name: String) -> String {
        switch name {
        case "외국어 공부":
            return "🌍"
        case "체력관리 및 운동":
            return "🏋🏻‍♀️"
        case "재테크/투자":
            return "💵"
        case "자격증 공부":
            return "🪪"
        case "직무 관련 역량 개발":
            return "👩🏻‍💻"
        default:
            return "📌"
        }
    }
}
