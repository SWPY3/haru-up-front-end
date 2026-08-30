//
//  ChatbotModels.swift
//  HaruUp
//
//  Created by 하다현 on 5/17/26.
//

// ── 요청 ──────────────────────────────────
// POST /chatbot/answer 에 보낼 body
struct ChatbotAnswerRequest: Encodable {
    let sessionId: String
    let answer: String
}

// POST /api/member/curation/chatbot-setup 에 보낼 body
struct ChatbotSetupRequest: Encodable {
    let characterId: Int
    let nickname: String
}

// POST /api/character/personality 에 보낼 body
struct SelectPersonalityRequest: Encodable {
    let personality: String
}

// ── 성격 ──────────────────────────────────
// GET /api/character/personality/list 응답 항목
struct PersonalityData: Codable {
    let code: String        // 선택 시 그대로 돌려보낼 값 (WARM_FRIEND / CLEAR_COACH)
    let label: String       // 사용자에게 보여줄 문구
}

// ── 응답 ──────────────────────────────────
/// 질문 유형. 서버가 새 값을 추가해도 앱이 죽지 않도록 unknown 으로 흡수한다.
enum ChatbotQuestionType: String, Codable {
    case aiFollowUp = "AI_FOLLOW_UP"    // AI가 대화 맥락에 맞춰 만든 꼬리질문
    case fixedTime = "FIXED_TIME"       // 투자 가능 시간을 묻는 고정 질문
    case unknown

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = ChatbotQuestionType(rawValue: raw) ?? .unknown
    }
}

// POST /chatbot/start 응답
struct ChatbotStartData: Codable {
    let sessionId: String
    let question: String
    /// 첫 질문에서는 항상 비어 있다.
    /// 사용자가 예시를 그대로 골라 목표가 구체화되지 않는 문제 때문에 서버가 선택지를 주지 않는다.
    let examples: [String]
    /// 입력창에 표시할 예시 (고를 수 없음)
    let placeholder: String?
    let questionNumber: Int
}

struct ChatbotMissionDto: Codable {
    let id: Int
    let missionContent: String
    let missionDescription: String?
    let difficulty: Int        // 1=하, 2=중, 3=상
    let expEarned: Int
}

/// answer API 는 네 가지 응답이 올 수 있어 하나의 모델로 받는다.
/// 어떤 응답인지는 `kind` 로 판별한다.
struct ChatbotAnswerResultData: Codable {
    // 공통
    let sessionId: String?

    // 진행 중 (다음 꼬리질문 또는 투자 가능 시간 질문)
    let question: String?
    let examples: [String]?
    let questionNumber: Int?
    let isLast: Bool?
    let questionType: ChatbotQuestionType?

    // 목표 검증 실패 (목표를 2개 이상 입력한 경우)
    let isValidGoal: Bool?
    let message: String?
    let detectedGoals: [String]?

    // 마무리 확인 (정보가 충분히 모였을 때)
    let awaitingFinishConfirmation: Bool?
    let answeredCount: Int?

    // 완료
    let isCompleted: Bool?
    let goalText: String?
    let missions: [ChatbotMissionDto]?

    /// 마무리 확인과 완료 응답 모두 사용자에게 보여줄 짧은 요약을 내려준다.
    let summary: String?

    /// 서버 응답 종류
    enum Kind {
        case goalRejected       // 목표를 하나만 입력하도록 되돌리기
        case finishConfirm      // 요약을 보여주고 마무리할지 묻기
        case nextQuestion       // 다음 질문 표시
        case completed          // 대화 종료, 미션 생성 완료
        case unknown
    }

    var kind: Kind {
        if isCompleted == true { return .completed }
        if isValidGoal == false { return .goalRejected }
        if awaitingFinishConfirmation == true { return .finishConfirm }
        if question != nil { return .nextQuestion }
        return .unknown
    }
}
