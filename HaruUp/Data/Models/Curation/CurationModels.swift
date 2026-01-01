//
//  CurationModels.swift
//  HaruUp
//
//  Created by 하다현 on 12/27/25.
//

import Foundation


// 백엔드로 보낼 요청 모델
struct CurationRequest: Encodable {
    let characterId: Int
    let nickname: String
    let birthDt: String
    let gender: String
    let jobId: Int
    let jobDetailId: Int
    let interests: [InterestRequest]
    
    struct InterestRequest: Encodable {
        let interestId: Int
        let directFullPath: [String]
    }
}


// 스트리밍으로 받을 응답 모델
struct CurationLog: Decodable {
    let step: String
    let message: String
    let donaAt: String
}


// 최종 응답 모델
struct CurationResponse: Decodable {
    let memberInterestIds: [Int]
}

// 로딩 단계 enum
enum LoadingStep: String {
    case characterCreated = "회원 캐릭터 정보 생성 완료"
    case profileSaved = "회원 기본 프로필 저장 완료"
    case jobSet = "회원 직업 정보 설정 완료"
    case jobDetailSet = "회원 직업 상세 정보 설정 완료"
    case interestSet = "회원 관심사 설정 완료"
    case goalSet = "회원 미션 설정 완료"
    
    var boxIndex: Int {
        switch self {
        case .characterCreated: return 0
        case .profileSaved: return 1
        case .jobSet, .jobDetailSet: return 2
        case .interestSet: return 3
        case .goalSet: return 4
        }
    }
}
