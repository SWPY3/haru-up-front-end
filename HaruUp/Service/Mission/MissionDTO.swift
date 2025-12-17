//
//  MissionDTO.swift
//  HaruUp
//
//  Created by 조영현 on 12/11/25.
//

import Foundation

/// 사용자의 관심사를 기반으로 AI로 미션 추천
struct MissionRecommendRequestDTO: Encodable {
    let userId: Int
    let interests: [InterestDTO]
}

struct InterestDTO: Encodable {
    let seqNo: Int
    let mainCategory: String
    let middleCategory: String
    let subCategory: String
    let difficulty: Int
}

struct MissionRecommendResponseDTO: Decodable {
    let missions: [RecommendedMissionDTO]
    let totalCount: Int
}

struct RecommendedMissionDTO: Decodable {
    let seqNo: Int
    let content: String
    let relatedInterest: String
    let difficulty: Int
}
