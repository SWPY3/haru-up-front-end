//
//  NicknameSelectModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/30/25.
//

//  유효성 검사 결과 타입 정의
enum ValidationResult {
    case success
    case empty
    case tooShort
    case tooLong
    case invalidCharacters      // 한글이 아닌 문자 포함 (숫자, 영어, 특수문자 등)
    case incompleteKorean        // 자음/모음이 섞인 경우
    case duplicated
}
