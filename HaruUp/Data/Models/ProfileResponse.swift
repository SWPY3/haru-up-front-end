//
//  ProfileResponse.swift
//  HaruUp
//
//  Created by 하다현 on 1/4/26.
//

import Foundation

struct ProfileResponse: Sendable, Codable {
    let success: Bool
    let data: ProfileData?
    let errorMessage: String?
}

struct ProfileData: Sendable, Codable {
    let id: Int
    let memberId: Int
    let nickname: String
    let birthDt: String?
    let gender: String?
    let imgId: Int?
    let intro: String?
    let jobId: Int?
    let jobDetailId: Int?
}
