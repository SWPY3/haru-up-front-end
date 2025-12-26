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
    
    /// 미션 재 요청
    struct RetryRecommendRequestDTO: Encodable {
        let memberInterestId: Int
        let excludeMemberMissionIds: [Int]
    }
    
    struct RetryRecommendResponseDTO: Decodable {
        let success: Bool
        let data: RetryMissionsDTO
        let errorMessage: String?
    }
    
    struct RetryMissionsDTO: Decodable {
        let missions: [RetryMissionsResponseDTO]
        let totalCount: Int
        let retryCount: Int
    }
    
    struct RetryMissionsResponseDTO: Decodable {
        let memberInterestId: Int
        let data: [RetryMissionDTO]
    }
    
    struct RetryMissionDTO: Decodable {
        let memberMissionId: Int
        let missionId: Int
        let content: String
        let directFullPath: [String]
        let difficulty: Int
        let expEarned: Int
        let createdType: String
        let relatedInterest: String?
        
        enum CodingKeys: String, CodingKey {
            case memberMissionId = "member_mission_id"
            case missionId = "mission_id"
            case content, directFullPath, difficulty, expEarned, createdType, relatedInterest
        }
        
        func toMissionDTO() -> MemberMission.MissionDTO {
            return MemberMission.MissionDTO(
                memberMissionId: self.memberMissionId,
                missionStatus: "WAITING",
                content: self.content,
                directFullPath: self.directFullPath,
                difficulty: self.difficulty,
                expEarned: self.expEarned,
                targetDate: ""
            )
        }
    }
}
