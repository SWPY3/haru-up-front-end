//
//  NetworkDefine.swift
//  HaruUp
//
//  Created by 조영현 on 12/11/25.
//

import Foundation

enum NetworkDefine {
    enum APIEnvironment {
        static let baseURL = "http://223.130.141.179:8080/"
    }
    
    enum AuthAPI {
        case snsLogin
        case logout
        
        var path: String {
            switch self {
            case .snsLogin:
                return "api/member/auth/sns-login"
            case .logout:
                return "api/member/auth/logout"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
    
    /// api/member
    enum MissionAPI {
        case recommend      /// 오늘의 미션 추천
        case retry          /// 오늘의 미션 재추천
        
        var path: String {
            switch self {
            case .recommend:
                return "api/member/mission/recommend"
            case .retry:
                return "api/member/mission/retry"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
    
    enum InterestsAPI {
        case member
        
        var path: String {
            switch self {
            case .member:
                return "api/interests/member"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
}
