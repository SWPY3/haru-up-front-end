//
//  MemberDTO.swift
//  HaruUp
//
//  Created by 조영현 on 1/3/26.
//

import Foundation

enum Member {
    struct HomeMemberInfoResponseDTO: Decodable {
        let success: Bool
        let data: [HomeMemberInfo]
        let errorMessage: String?
    }
    
    struct HomeMemberInfo: Decodable {
        let characterId: Int
        let totalExp: Int
        let currentExp: Int
        let maxExp: Int
        let levelNumber: Int
        let nickname: String
        let interests: [[String]]
    }
}
