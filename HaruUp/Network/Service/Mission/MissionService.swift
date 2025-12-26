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
    // Home에서 미션 선택창을 띄워야하는지 여부
    func needShowTodayMissionFlow() -> Single<Bool>
    // 미션 추천
    func fetchRecommendedMissions(memberInterestId: Int) -> Single<MemberMission.MissionRecommendResponseDTO>
    // 미션 재추천
    func retryRecommendMissions(memberInterestId: Int, excludeMissionIDs: [Int]) -> Single<MemberMission.RetryRecommendResponseDTO>
    // 미션 선택 완료
    func selectMissions(missionIDs: [Int]) -> Single<MemberMission.SelectMissionResponseDTO>
    func markTodayMissionSelected() // UserDefaults 갱신
}

final class MissionService: Service, MissionServiceProtocol {
    private let defaults = UserDefaults.standard
    
    func fetchRecommendedMissions(memberInterestId: Int) -> Single<MemberMission.MissionRecommendResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.recommend.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0IiwibmFtZSI6IiIsInR5cGUiOiJBQ0NFU1MiLCJpYXQiOjE3NjY1NjM5NjQsImV4cCI6MTc3NTIwMzk2NH0.azu1SOj9BQdQkYQeQ17Dv05sShVGXJYogmOEqZYAZjM"
        
        let query = MemberMission.RecommendRequestDTO(memberInterestId: memberInterestId)

        return request(url, method: .get, header: headers, query: query)
    }
    
    func retryRecommendMissions(memberInterestId: Int, excludeMissionIDs: [Int]) -> Single<MemberMission.RetryRecommendResponseDTO> {
        let url: String = NetworkDefine.MissionAPI.retry.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"

        headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0IiwibmFtZSI6IiIsInR5cGUiOiJBQ0NFU1MiLCJpYXQiOjE3NjY1NjM5NjQsImV4cCI6MTc3NTIwMzk2NH0.azu1SOj9BQdQkYQeQ17Dv05sShVGXJYogmOEqZYAZjM"
        
        let body = MemberMission.RetryRecommendRequestDTO(memberInterestId: memberInterestId, excludeMemberMissionIds: excludeMissionIDs)
        
        return request(url, method: .post, header: headers, body: body)
    }
    
    func selectMissions(missionIDs: [Int]) -> Single<MemberMission.SelectMissionResponseDTO> {
        let url: String = NetworkDefine.MissionAPI.select.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"

        headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0IiwibmFtZSI6IiIsInR5cGUiOiJBQ0NFU1MiLCJpYXQiOjE3NjY1NjM5NjQsImV4cCI6MTc3NTIwMzk2NH0.azu1SOj9BQdQkYQeQ17Dv05sShVGXJYogmOEqZYAZjM"
        
        let body = MemberMission.SelectMissionRequestDTO(memberMissionIds: missionIDs)
        
        return request(url, method: .post, header: headers, body: body)
    }
}

// MARK: UserDefaults - 미션 선택 여부
extension MissionService {
    func needShowTodayMissionFlow() -> Single<Bool> {
        let today = Self.todayString()
        let saved = defaults.string(forKey: UserDefaultsKey.todayMissionSelectedDate)
        let needShow = (saved != today)
        return .just(needShow)
    }
    
    func markTodayMissionSelected() {
        let today = Self.todayString()
        defaults.set(today, forKey: UserDefaultsKey.todayMissionSelectedDate)
    }
    
    private static func todayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
