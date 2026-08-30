//
//  CharacterService.swift
//  HaruUp
//

import Foundation
import RxSwift
import Alamofire

/// 캐릭터 목록과 AI 성격을 다루는 API.
final class CharacterService: Service {

    private func authHeader() -> Alamofire.HTTPHeaders {
        var headers: HTTPHeaders = ["Content-type": "application/json"]

        if let token = TokenStorageService.shared.getRefreshToken() {
            headers.add(name: "jwt-token", value: token)
        }
        return headers
    }

    /// 선택 가능한 캐릭터 목록.
    /// 이 API 는 다른 API 와 달리 배열을 그대로 반환한다.
    func characterList() -> Single<[CharacterData]> {
        return request(NetworkDefine.CharacterAPI.list.url, method: .get, header: authHeader())
    }

    /// 선택 가능한 AI 성격 목록
    func personalityList() -> Single<GenericResponse<[PersonalityData]>> {
        return request(NetworkDefine.CharacterAPI.personalityList.url, method: .get, header: authHeader())
    }

    /// AI 성격 선택 (캐릭터 선택 이후, 챗봇 시작 전)
    func selectPersonality(_ code: String) -> Single<GenericResponse<String>> {
        let body = SelectPersonalityRequest(personality: code)
        return request(NetworkDefine.CharacterAPI.selectPersonality.url, method: .post, header: authHeader(), body: body)
    }
}
