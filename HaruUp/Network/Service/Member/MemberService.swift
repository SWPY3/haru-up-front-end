//
//  MemberService.swift
//  HaruUp
//
//  Created by 조영현 on 1/3/26.
//

import Foundation
import RxSwift
import Alamofire

final class MemberService: Service {
    
    func fetchHomeMemberInfo() -> Single<Member.HomeMemberInfoResponseDTO> {
        let url: String = NetworkDefine.MemberAPI.Account.homeMemberInfo.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        
        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return request(url, method: .post, header: headers)
    }
}
