//
//  ChatbotService.swift
//  HaruUp
//
//  Created by 하다현 on 5/17/26.
//

import Foundation
import RxSwift
//import NetworkKit
import Alamofire

final class ChatbotService: Service {
    
    private func authHeader() -> Alamofire.HTTPHeaders {
        var headers: HTTPHeaders = ["Content-type" : "application/json"]
        
        if let token = TokenStorageService.shared.getRefreshToken() {
            headers.add(name: "jwt-token", value: token)
        }
        return headers
    }
    
    // 챗봇 시작 - sessionId + 첫 질문 반환
    func start() -> Single<GenericResponse<ChatbotStartData>> {
        return request(NetworkDefine.ChatbotAPI.start.url, method: .post, header: authHeader())
    }
    
    // 사용자 답변 제출 - 다음 질문 or 완료 반환
    func answer(sessionId: String, answer: String) -> Single<GenericResponse<ChatbotAnswerResultData>> {
        let body = ChatbotAnswerRequest(sessionId: sessionId, answer: answer)
        return request(NetworkDefine.ChatbotAPI.answer.url, method: .post, header: authHeader(), body: body)
    }

    // 챗봇 온보딩 완료 후 캐릭터 + 닉네임 저장
    func chatbotSetup(characterId: Int, nickname: String) -> Single<GenericResponse<String>> {
        let body = ChatbotSetupRequest(characterId: characterId, nickname: nickname)
        return request(NetworkDefine.ChatbotAPI.chatbotSetup.url, method: .post, header: authHeader(), body: body)
    }
}
