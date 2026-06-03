//
//  CurationData.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import Foundation

class CurationData: Codable{
    var characterId: Int?
    var nickname: String?
    var job: Job?
    var jobDetail: JobDetail?
    var gender: String?
    var birthDate: String?
    var interest: InterestData?
    var interestDetail: InterestData?
    var goal: InterestData?
    
    var memberInterestIds: [Int]?

    /// 챗봇 완료 후 받은 미션 목록 (선택 화면에 전달용, 로컬 전달 전용)
    var chatbotMissions: [ChatbotMissionDto]?

    init() {}
    
    
    // 모든 데이터가 입력되었는지 확인
    func isCompleted() -> Bool {
        return characterId != nil &&
        nickname != nil &&
        job != nil &&
        gender != nil &&
        birthDate != nil &&
        interest != nil &&
        interestDetail != nil &&
        goal != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case job
        case jobDetail
        case interest
        case interestDetail
        case goal
        case memberInterestIds
    }
}

extension CurationData {
    // 생년월일 포맷 변환 (19950730 -> 1995-07-30)
    func formatBirthDate() -> String {
        guard let birthDate = birthDate, birthDate.count == 8 else {
            return ""
        }
        
        let year = birthDate.prefix(4)
        let month = birthDate.dropFirst(4).prefix(2)
        let day = birthDate.suffix(2)
        
        return "\(year)-\(month)-\(day)"
    }
    
    // 성별 변환 (남성/여성 -> MALE/FEMALE)
    func formatGender() -> String {
        guard let gender = gender else { return "" }
        
        switch gender {
        case "남성":
            return "MALE"
        case "여성":
            return "FEMALE"
        default:
            return ""
        }
    }
    
    // 백엔드 요청 모델로 변환
    func toCurationRequest() -> CurationRequest? {
        // 디버깅: 어떤 값이 없는지 확인
        print("=== CurationData 디버깅 ===")
        print("characterId: \(characterId ?? -999)")
        print("nickname: \(nickname ?? "없음")")
        print("job: \(job?.id ?? -999)")
        print("jobDetail: \(jobDetail?.id ?? -999)")
        print("goal: \(goal?.name ?? "없음")")
        print("interest: \(interest?.name ?? "없음")")
        print("interestDetail: \(interestDetail?.name ?? "없음")")
        print("interestDetailID: \(interestDetail?.id ?? -999)")
        
        guard let characterId = characterId else {
            print("❌ characterId가 없습니다")
            return nil
        }
        
        guard let nickname = nickname else {
            print("❌ nickname이 없습니다")
            return nil
        }
        
        guard let jobId = job?.id else {
            print("❌ job.id가 없습니다")
            return nil
        }
        
        let jobDetailId = jobDetail?.id
        
        // ✅ interestId는 goal의 id
        guard let interestId = goal?.id else {
            print("❌ interestDetail.id가 없습니다")
            return nil
        }
        
        // ✅ directFullPath는 [interest, interestDetail, goal]의 이름들
        var path: [String] = []
        
        if let interestName = interest?.name {
            path.append(interestName)
        }
        
        if let interestDetailName = interestDetail?.name {
            path.append(interestDetailName)
        }
        
        if let goalName = goal?.name {
            path.append(goalName)
        }
        
        print("✅ interestId (interestDetail.id): \(interestId)")
        print("✅ directFullPath: \(path)")
        
        let interestRequest = CurationRequest.InterestRequest(
            interestId: interestId,
            directFullPath: path
        )
        
        let request = CurationRequest(
            characterId: characterId,
            nickname: nickname,
            birthDt: formatBirthDate(),
            gender: formatGender(),
            jobId: jobId,
            jobDetailId: jobDetailId,
            interests: [interestRequest]
        )
        
        print("✅ CurationRequest 생성 완료!")
        return request
    }
}


extension CurationData {
    var primaryMemberInterestId: Int? {
        return memberInterestIds?.first
    }
}
