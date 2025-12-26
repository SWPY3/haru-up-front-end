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
    
    enum ProfileAPI {
        case nicknameDuplicateCheck
        
        var path: String {
            switch self {
            case .nicknameDuplicateCheck:
                return "api/member/profile/nickName_duplicate_check"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
    
    enum JobAPI {
        case getJobList
        case getJobDetailList(jobId: Int)
        
        var path: String {
            switch self {
            case .getJobList:
                return "api/job/getJobList"
            case .getJobDetailList:
                return "api/job/getJobDetailList"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
    
    
    enum InterestAPI {
            case getInterestList
            case getInterestDetail(parentId: Int)
            case getGoalList(parentId: Int)
            
            var path: String {
                return "api/interests/data"
            }
            
            var url: String {
                return APIEnvironment.baseURL + self.path
            }
        }
    
    enum CurationAPI {
        case initialCuration
        
        var path: String {
            switch self {
            case .initialCuration:
                return "api/member/curation/initial"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
}
