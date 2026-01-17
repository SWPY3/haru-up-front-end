//
//  HistoryDTO.swift
//  HaruUp
//
//  Created by 조영현 on 1/16/26.
//

import Foundation

enum MissionHistory {
    struct HistoryRequestDTO: Encodable {
        let targetMonth: String
    }
    
    struct HistoryResponseDTO: Decodable {
        let success: Bool
        let data: [HistoryDTO]
        let errorMessage: String?
    }
    
    struct HistoryDTO: Decodable {
        let targetDate: String
        let completedCount: Int
    }
}
