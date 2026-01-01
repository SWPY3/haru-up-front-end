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
    
    func fetchInterests() -> Single<Interests.InterestsDTO> {
        
        let url: String = NetworkDefine.InterestsAPI.member.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        
        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return request(url, method: Alamofire.HTTPMethod.get, header: headers)
    }
}
