//
//  Chart.swift
//  HaruUp
//
//  Created by 하다현 on 1/7/26.
//

import UIKit

struct RankingResponse: Decodable {
    let success: Bool
    let data: [ChartItem]? 
    let errorMessage: String?
}

// 차트 아이템 모델
struct ChartItem: Codable {
    let rank: Int
    let title: String
    let tags: [String]
    let count: Int
    
    // 서버의 키값과 앱의 변수명을 매핑
    enum CodingKeys: String, CodingKey {
        case rank
        case title = "labelName"
        case tags = "interestFullPath"
        case count = "selectionCount"     
    }
}

