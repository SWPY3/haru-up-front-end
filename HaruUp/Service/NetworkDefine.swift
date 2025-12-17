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
    
    enum MissionAPI {
        case recommend
        
        var path: String {
            switch self {
            case .recommend:
                return "api/mission/recommend"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
}
