//
//  Job.swift
//  HaruUp
//
//  Created by 하다현 on 12/24/25.
//

import Foundation


// 직업 목록 응답
struct Job: Codable, Sendable, DropdownDisplayable {
    let id: Int
    let jobName: String
    
    var displayName: String { return jobName }
}

// 직업 상세 목록 응답
struct JobDetail: Codable, Sendable, DropdownDisplayable {
    let id: Int
    let jobDetailName: String
    
    var displayName: String { return jobDetailName }
}
