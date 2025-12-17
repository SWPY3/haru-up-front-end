//
//  CurationData.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import Foundation

class CurationData {
    var characterId: Int?
    var nickname: String?
    var job: String?
    var jobDetail: String?
    var gender: String?
    var birthDate: String?
    var interest: String?
    var interestDetail: String?
    var goal: String?
    
    init() {}
    
    
    // 모든 데이터가 입력되었는지 확인
    func isCompleted() -> Bool {
        return characterId != nil &&
        nickname != nil &&
        job != nil &&
        jobDetail != nil &&
        gender != nil &&
        birthDate != nil &&
        interest != nil &&
        interestDetail != nil
//        goal != nil
    }
    
    // 백엔드로 보낼 딕셔너리 형태로 변환
        func toDictionary() -> [String: Any] {
            return [
                "characterId": characterId ?? 999,
                "nickname": nickname ?? "",
                "job": job ?? "",
                "jobDetail": jobDetail ?? "",
                "gender": gender ?? "",
                "birthDate": birthDate ?? "",
                "interest": interest ?? "",
                "interestDetail": interestDetail ?? "",
            ]
        }
}
