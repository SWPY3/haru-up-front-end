//
//  BirthSelectModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/31/25.
//

enum BirthValidationResult {
    case success    // 성공
    case empty      // 빈 문자열
    case tooShort
    case tooLong
    case invalid    // 유효하지 않은 날짜
}
