//
//  InterestsService.swift
//  HaruUp
//
//  Created by 조영현 on 12/25/25.
//

import Foundation
import RxSwift
import Alamofire

final class InterestsService: Service {
    
    // MARK: - Fetch Interests
    // 관심사 목록 가져오기
    func fetchInterests() -> Single<Interests.InterestsDTO> {
        
        let url: String = NetworkDefine.InterestsAPI.member.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        
        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return request(url, method: Alamofire.HTTPMethod.get, header: headers)
    }
}
