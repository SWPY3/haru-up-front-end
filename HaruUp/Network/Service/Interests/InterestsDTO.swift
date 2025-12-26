//
//  InterestsDTO.swift
//  HaruUp
//
//  Created by 조영현 on 12/25/25.
//

import Foundation

enum Interests {
    /// 사용자가 선택한 관심사 목록 조회
    struct InterestsDTO: Decodable {
        let interests: [InterestDTO]
        let totalCount: Int
    }

    struct InterestDTO: Decodable {
        let memberInterestId: Int
        let memberId: Int
        let interestId: Int
        let directFullPath: [String]
        let resetMissionCount: Int
        let createdAt: String
        let updatedAt: String
        let fullPath: [String]

        enum CodingKeys: String, CodingKey {
            case memberInterestId = "member_interest_id"
            case memberId, interestId, directFullPath, resetMissionCount, createdAt, updatedAt, fullPath
        }
    }
}
