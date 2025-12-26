//
//  MissionDTO.swift
//  HaruUp
//
//  Created by 조영현 on 12/11/25.
//

import Foundation

enum MemberMission {
    /// 사용자의 관심사를 기반으로 AI로 미션 추천
    struct RecommendRequestDTO: Encodable {
        let memberInterestId: Int
    }

    struct MissionRecommendResponseDTO: Decodable {
        let success: Bool
        let data: MissionsDTO
        let errorMessage: String?
    }
    
    struct MissionsDTO: Decodable {
        let missions: [MissionDTO]
        let retryCount: Int
    }

    struct MissionDTO: Decodable {
        let memberMissionId: Int
        let missionStatus: String
        let content: String
        let directFullPath: [String]
        let difficulty: Int
        let expEarned: Int
        let targetDate: String
    }
}
