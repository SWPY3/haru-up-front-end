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
    // MARK: UserDefaults
    private let defaults = UserDefaults.standard
    
    var selectedMemberInterestId: Int? {
        get {
            let value = defaults.integer(forKey: UserDefaultsKey.selectedMemberInterestId)
            return defaults.object(forKey: UserDefaultsKey.selectedMemberInterestId) == nil ? nil : value
        }
        set {
            if let newValue {
                defaults.set(newValue, forKey: UserDefaultsKey.selectedMemberInterestId)
            } else {
                defaults.removeObject(forKey: UserDefaultsKey.selectedMemberInterestId)
            }
        }
    }
    
    func fetchInterests() -> Single<Interests.InterestsDTO> {
        
        let url: String = NetworkDefine.InterestsAPI.member.url
        
        var headers: HTTPHeaders = ["Accept": "application/json"]
        
        headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0IiwibmFtZSI6IiIsInR5cGUiOiJBQ0NFU1MiLCJpYXQiOjE3NjY1NjM5NjQsImV4cCI6MTc3NTIwMzk2NH0.azu1SOj9BQdQkYQeQ17Dv05sShVGXJYogmOEqZYAZjM"
        
        return request(url, method: Alamofire.HTTPMethod.get, header: headers)
    }
}
