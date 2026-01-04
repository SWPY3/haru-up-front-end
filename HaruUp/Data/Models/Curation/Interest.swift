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
        case "재테크 및 투자":
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

struct MemberInterestResponse: Decodable {
    let interests: [MemberInterestDTO]
    let totalCount: Int
}

// 리스트 내부 아이템
struct MemberInterestDTO: Codable {
    let memberInterestId: Int
    let memberId: Int
    let interestId: Int // 이게 '목표'의 ID입니다.
    let directFullPath: [String] // ["관심사", "세부관심사", "목표"]
    
    // JSON의 snake_case를 camelCase로 매핑
    enum CodingKeys: String, CodingKey {
        case memberInterestId = "member_interest_id"
        case memberId
        case interestId
        case directFullPath
    }
}

// MARK: - Interest Extension
extension Interest: DropdownDisplayable {
    var displayName: String {
        return title
    }
    
    // memberInterestId는 CurationData에서 가져온 Interest에만 존재
    // API 응답에서 새로 가져온 Interest에는 없을 수 있음
    var memberInterestId: Int? {
        // 이 값은 InterestDTO에서 가져와야 하므로 별도 처리 필요
        return nil
    }
}

struct InterestDetail: DropdownDisplayable {
    let id: Int
    let name: String
    
    var displayName: String {
        return name
    }
    
    init(from data: InterestData) {
        self.id = data.id
        self.name = data.name
    }
}

// MARK: - Goal Model
struct Goal: DropdownDisplayable {
    let id: Int
    let name: String
    
    var displayName: String {
        return name
    }
    
    init(from data: InterestData) {
        self.id = data.id
        self.name = data.name
    }
}
