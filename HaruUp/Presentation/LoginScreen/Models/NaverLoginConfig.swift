//
//  NaverLoginConfig.swift
//  HaruUp
//
//  Created by 하다현 on 12/4/25.
//

import Foundation


enum NaverLoginConfig {
    static let appName: String = "HaruUp"             // 네이버 동의창에 뜨는 이름
    static let clientId: String = "8N9gaq5jOl22B_gCpZlu"    // 네이버 콘솔에서 발급
    // TODO: - clientSecret 입력
    static let clientSecret: String = "YOUR_SECRET"   // 네이버 콘솔에서 발급
    static let urlScheme: String = "naver8N9gaq5jOl22B_gCpZlu" // 위에서 Info.plist에 넣은 그 값
}
