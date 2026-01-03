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
        case withdraw
        
        var path: String {
            switch self {
            case .snsLogin:
                return "api/member/auth/sns-login"
            case .logout:
                return "api/member/auth/logout"
            case .withdraw:
                return "api/member/account/withdraw"
            }
        }
        
        var url: String {
            return APIEnvironment.baseURL + self.path
        }
    }
    
    /// api/member
    enum MissionAPI {
        case recommend             /// 오늘의 미션 추천
        case recommendMultiple     /// 다수의 관심사의 미션을 추천
        case retry                 /// 오늘의 미션 재추천
        case select                /// 오늘의 미션 선택
        case list                  /// 오늘의 미션 목록
        case status                /// 미션 성공 및 실패
        
        var path: String {
            switch self {
            case .recommend:
                return "api/member/mission/recommend"
            case .recommendMultiple:
                return "api/missions/recommend"
            case .retry:
                return "api/member/mission/retry"
            case .select:
                return "api/member/mission/select"
            case .list:
                return "api/member/mission"
            case .status:
                return "api/member/mission/status"
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
    
    enum ProfileAPI {
        case nicknameDuplicateCheck
        case updateProfile
        case getProfile
        
        var path: String {
            switch self {
            case .nicknameDuplicateCheck:
                return "api/member/profile/nickName_duplicate_check"
            case .updateProfile, .getProfile:
                return "api/member/profile/profile"
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
        case validation
        
        var path: String {
            switch self {
            case .getInterestList, .getInterestDetail, .getGoalList:
                return "api/interests/data"
            case .validation:
                return "api/interests/interest/validation" 
            }
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
