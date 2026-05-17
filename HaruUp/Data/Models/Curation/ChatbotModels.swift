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

// ── 응답 ──────────────────────────────────
// POST /chatbot/start 응답
struct ChatbotStartData: Decodable {
    let sessionId: String
    let question: String
    let examples: [String]
    let questionNumber: Int
}

// POST /chatbot/answer 응답 — 진행 중 (Q2~Q5)
struct ChatbotNextQuestionData: Decodable {
    let sessionId: String
    let question: String
    let questionNumber: Int
    let isLast: Bool           // true면 마지막 질문 안내 가능
}

// POST /chatbot/answer 응답 — 완료 (Q6 답변 후)
struct ChatbotCompleteData: Decodable {
    let isCompleted: Bool
    let goalText: String
    let missions: [ChatbotMissionDto]
}

struct ChatbotMissionDto: Decodable {
    let id: Int
    let missionContent: String
    let missionDescription: String?
    let difficulty: Int        // 1=하, 2=중, 3=상
    let expEarned: Int
}

// answer API는 진행 중/완료 두 가지 응답이 올 수 있어서
// 하나의 통합 모델로 처리 (모든 필드 optional)
struct ChatbotAnswerResultData: Decodable {
    // 진행 중 필드
    let sessionId: String?
    let question: String?
    let questionNumber: Int?
    let isLast: Bool?
    // 완료 필드
    let isCompleted: Bool?
    let goalText: String?
    let missions: [ChatbotMissionDto]?
}
