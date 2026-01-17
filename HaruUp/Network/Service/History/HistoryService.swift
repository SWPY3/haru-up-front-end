//
//  HistoryService.swift
//  HaruUp
//
//  Created by 조영현 on 1/16/26.
//

import Foundation
import RxSwift
import Alamofire

protocol HistoryServiceProtocol {
    func fetchMonthlyMissions(targetMonth: String) -> Single<MissionHistory.HistoryResponseDTO>
}

final class HistoryService: Service, HistoryServiceProtocol {
    
    func fetchMonthlyMissions(targetMonth: String) -> Single<MissionHistory.HistoryResponseDTO> {
        let url: String = NetworkDefine.MissionAPI.history.url + "/\(targetMonth)"
        
        var headers: HTTPHeaders = ["Accept": "application/json"]

        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return request(url, method: .post, header: headers)
    }
}
