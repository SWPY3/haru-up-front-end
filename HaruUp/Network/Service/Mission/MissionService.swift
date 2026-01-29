//
//  MissionService.swift
//  HaruUp
//
//  Created by 조영현 on 12/11/25.
//

import Foundation
import RxSwift
import Alamofire

protocol MissionServiceProtocol {
    // 미션 추천
    func requestRecommendedMissions(memberInterestId: Int) -> Single<MemberMission.MissionRecommendResponseDTO>
    // 다양한 관심사로 미션 추천
    func requestRecommendedMultipleMissions(memberInterestIds: [Int]) -> Single<MemberMission.RecommendMultipleResponseDTO>
    // 미션 재추천
    func retryRecommendMissions(memberInterestId: Int, excludeMissionIDs: [Int]) -> Single<MemberMission.RetryRecommendResponseDTO>
    // 미션 선택 완료
    func selectMissions(missionIDs: [Int]) -> Single<MemberMission.SelectMissionResponseDTO>
    // 미션 목록 표시
    func fetchMissionList(memberInterestId: Int, targetDate: String, status: [MemberMission.MissionStatusType]) -> Single<MemberMission.FetchMissionResponseDTO>
    // 미션 완료 및 삭제
    func setMissionStatus(id: Int, status: String) -> Single<MemberMission.MissionStatusResponseDTO>
    // 미션 달성 일정
    func fetchChallengeDate() -> Single<MemberMission.ChallengeResponseDTO>
    // 월별 미션 완료일
    func fetchMonthlyMissions(targetMonth: String) -> Single<MemberMission.HistoryResponseDTO>
}

final class MissionService: Service, MissionServiceProtocol {
    
    func requestRecommendedMissions(memberInterestId: Int) -> Single<MemberMission.MissionRecommendResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.recommend.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let query = MemberMission.RecommendRequestDTO(memberInterestId: memberInterestId)

        return request(url, method: .get, header: headers, query: query)
    }
    
    func requestRecommendedMultipleMissions(memberInterestIds: [Int]) -> Single<MemberMission.RecommendMultipleResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.recommendMultiple.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let body = MemberMission.RecommendMultipleRequestDTO(memberInterestIds: memberInterestIds)

        return request(url, method: .post, header: headers, body: body)
    }
    
    func retryRecommendMissions(memberInterestId: Int, excludeMissionIDs: [Int]) -> Single<MemberMission.RetryRecommendResponseDTO> {
        let url: String = NetworkDefine.MissionAPI.retry.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let body = MemberMission.RetryRecommendRequestDTO(memberInterestId: memberInterestId, excludeMemberMissionIds: excludeMissionIDs)
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func selectMissions(missionIDs: [Int]) -> Single<MemberMission.SelectMissionResponseDTO> {
        let url: String = NetworkDefine.MissionAPI.select.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let body = MemberMission.SelectMissionRequestDTO(memberMissionIds: missionIDs)
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func fetchMissionList(memberInterestId: Int, targetDate: String, status: [MemberMission.MissionStatusType]) -> Single<MemberMission.FetchMissionResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.list.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        
        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let statusString = status.map { $0.rawValue }.joined(separator: ",")
        
        let query = MemberMission.FetchMissionRequestDTO(
            missionStatus: statusString,
            targetDate: targetDate,
            memberInterestId: memberInterestId
        )

        return request(url, method: .get, header: headers, query: query)
    }
    
    func setMissionStatus(id: Int, status: String) -> Single<MemberMission.MissionStatusResponseDTO> {
        let url: String = NetworkDefine.MissionAPI.status.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let body = MemberMission.MissionStatusRequestDTO(missions: [MemberMission.MemberMissionDTO(memberMissionId: id, missionStatus: status)])
        
        return request(url, method: .put, header: headers, body: body)
    }
    
    func fetchChallengeDate() -> Single<MemberMission.ChallengeResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.challenge.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let date = getDateRangeStrings()
        let startDate = date.sixDaysAgo
        let endDate = date.today
        
        let query = MemberMission.ChallengeRequestDTO(startDate: startDate, endDate: endDate)

        return request(url, method: .get, header: headers, query: query)
    }
    
    func fetchMonthlyMissions(targetMonth: String) -> Single<MemberMission.HistoryResponseDTO> {
        
        print("fetchMonthlyMissions")
        
        let url: String = NetworkDefine.MissionAPI.history.url + "/\(targetMonth)"
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return request(url, method: .post, header: headers)
    }
}

// MARK: 오늘 포함 7일간의 날짜 계산
extension MissionService {
    func getDateRangeStrings() -> (today: String, sixDaysAgo: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")   // 한국 시간 기준
        formatter.timeZone = TimeZone.current            // 현재 기기 시간대 사용
        
        let now = Date()
        
        let sixDaysAgoDate = Calendar.current.date(byAdding: .day, value: -6, to: now) ?? now
        
        let todayString = formatter.string(from: now)
        let sixDaysAgoString = formatter.string(from: sixDaysAgoDate)
        
        return (today: todayString, sixDaysAgo: sixDaysAgoString)
    }
    
    private static func todayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
