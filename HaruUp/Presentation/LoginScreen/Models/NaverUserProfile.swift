//
//  NaverUserProfileModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/4/25.
//

import Foundation


struct NaverUserProfile {
    let id: String
    let name: String
    let email: String
    
    
    init?(dictionary: [String: String]) {
        // id는 항상 있어야 함
        guard let id = dictionary["id"] else { return nil }
        self.id = id
        self.name = dictionary["name"] ?? ""
        self.email = dictionary["email"] ?? ""
    }
}
