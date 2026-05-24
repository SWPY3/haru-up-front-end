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
        
        static let empty = Self(memberMissionId: 0, missionStatus: "", content: "", directFullPath: [], difficulty: 0, expEarned: 0, targetDate: "")
    }
    
    /// 여러 관심사를 입력했을 대 얻을 수 있는 미션 추천
    struct RecommendMultipleRequestDTO: Encodable {
        let memberInterestIds: [Int]
    }

    struct RecommendMultipleResponseDTO: Decodable {
        let success: Bool
        let data: MultipleDataDTO
        let errorMessage: String?
    }
    
    struct MultipleDataDTO: Decodable {
        let missions: [MultipleMissionsDTO]
        let totalCount: Int
        let retryCount: Int
    }

    struct MultipleMissionsDTO: Decodable {
        let memberInterestId: Int
        let data: [MultipleMissionDTO]
    }
    
    struct MultipleMissionDTO: Decodable {
        let memberMissionId: Int
        let content: String
        let directFullPath: [String]
        let difficulty: Int
        let expEarned: Int
        let createdType: String
        
        enum CodingKeys: String, CodingKey {
            case memberMissionId = "member_mission_id"
            case content, directFullPath, difficulty, expEarned, createdType
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
        let content: String
        let directFullPath: [String]
        let difficulty: Int
        let expEarned: Int
        let createdType: String
        
        enum CodingKeys: String, CodingKey {
            case memberMissionId = "member_mission_id"
            case content, directFullPath, difficulty, expEarned, createdType
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
    
    // MARK: 미션 선택
    struct SelectMissionRequestDTO: Encodable {
        let memberMissionIds: [Int]
    }
    
    struct SelectMissionResponseDTO: Decodable {
        let success: Bool
        let data: [Int]
        let errorMessage: String?
    }
    
    // MARK: 미션 목록
    enum MissionStatusType: String {
        case active = "ACTIVE"
        case inactive = "INACTIVE"
        case completed = "COMPLETED"
    }
    
    struct FetchMissionRequestDTO: Encodable {
        let missionStatus: String // ACTIVE, INACTIVE, COMPLETED
        let targetDate: String // yyyy-MM-dd
        let memberInterestId: Int? // nil이면 백엔드에서 전체 미션 반환
    }
    
    struct FetchMissionResponseDTO: Decodable {
        let success: Bool
        let data: [MissionListDTO]
        let errorMessage: String?
    }
    
    struct MissionListDTO: Decodable {
        let id: Int
        let memberId: Int
        let memberInterestId: Int
        let missionStatus: String
        let expEarned: Int
        let targetDate: String
        let missionContent: String
        let difficulty: Int
        let fullPath: [String]?        // 챗봇 생성 미션은 null
        let directFullPath: [String]?  // 챗봇 생성 미션은 null
    }
    
    // MARK: 미션 상태
    struct MissionStatusRequestDTO: Encodable {
        let missions: [MemberMissionDTO]
    }
    
    struct MemberMissionDTO: Encodable {
        let memberMissionId: Int
        let missionStatus: String
    }
    
    struct MissionStatusResponseDTO: Decodable {
        let success: Bool
        let data: String
        let errorMessage: String?
    }
    
    // MARK: 연속 미션 달성일
    struct ChallengeRequestDTO: Encodable {
        let startDate: String   // yyyy-MM-dd
        let endDate: String     // yyyy-MM-dd
    }
    
    struct ChallengeResponseDTO: Decodable {
        let success: Bool
        let data: [ChallengeDataDTO]
        let errorMessage: String?
    }
    
    struct ChallengeDataDTO: Decodable {
        let targetDate: String  // yyyy-MM-dd
        let isCompleted: Bool
    }
    
    // MARK: 월별 미션 완료
    struct HistoryRequestDTO: Encodable {
        let targetMonth: String
    }
    
    struct HistoryResponseDTO: Decodable {
        let success: Bool
        let data: HistoryDTO
        let errorMessage: String?
    }
    
    struct HistoryDTO: Decodable {
        let missionCounts: [MissionCountDTO]
        let totalMissionCount: Int
        let totalCompletedDays: Int
    }
    
    struct MissionCountDTO: Decodable {
        let targetDate: String
        let completedCount: Int
    }
    
    // MARK: 월별 성장 차트
    struct GrowthRequestDTO: Encodable {
        let startTargetMonth: String // yyyy-MM
        let endTargetMonth: String   // yyyy-MM
    }
    
    struct GrowthResponseDTO: Decodable {
        let success: Bool
        let data: GrowthDataDTO
        let errorMessage: String?
    }
    
    struct GrowthDataDTO: Decodable {
        let monthlyData: [AttendanceDate]
    }
    
    struct AttendanceDate: Decodable {
        let targetMonth: String // yyyy-MM
        let completedDays: Int
    }
}
