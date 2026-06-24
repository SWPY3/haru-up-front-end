//
//  MissionSource.swift
//  HaruUp
//
//  Created by Codex on 6/24/26.
//

import Foundation

enum MissionSource: Equatable {
    static let chatbotGoalInterestId = 0

    case chatbot
    case interest(ids: [Int])

    init(memberInterestIds: [Int]) {
        let interestIds = memberInterestIds.filter { $0 != Self.chatbotGoalInterestId }
        self = interestIds.isEmpty ? .chatbot : .interest(ids: interestIds)
    }

    var recommendationMemberInterestIds: [Int] {
        switch self {
        case .chatbot:
            return [Self.chatbotGoalInterestId]
        case .interest(let ids):
            return ids
        }
    }

    var retryMemberInterestId: Int {
        switch self {
        case .chatbot:
            return Self.chatbotGoalInterestId
        case .interest(let ids):
            return ids.first ?? Self.chatbotGoalInterestId
        }
    }

    var shouldSendRetryExcludeMissionIds: Bool {
        switch self {
        case .chatbot:
            return false
        case .interest:
            return true
        }
    }
}
