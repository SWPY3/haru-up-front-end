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
    // 미션 목록 표시
    func fetchMissionList() -> Single<MemberMission.FetchMissionResponseDTO>
    // 미션 완료 및 삭제
    func setMissionStatus(id: Int, status: String) -> Single<MemberMission.MissionStatusResponseDTO>
}

final class MissionService: Service, MissionServiceProtocol {
    private let defaults = UserDefaults.standard
    
    func fetchRecommendedMissions(memberInterestId: Int) -> Single<MemberMission.MissionRecommendResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.recommend.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let query = MemberMission.RecommendRequestDTO(memberInterestId: memberInterestId)

        return request(url, method: .get, header: headers, query: query)
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
    
    func fetchMissionList() -> Single<MemberMission.FetchMissionResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.list.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let query = MemberMission.FetchMissionRequestDTO()

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
