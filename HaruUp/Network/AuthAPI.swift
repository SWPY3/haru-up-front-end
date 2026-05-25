//
//  AuthAPI.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation
import RxSwift
import Alamofire

protocol AuthAPIProtocol {
    func socialLogin(request: SocialLoginRequestDTO) -> Single<SocialLoginResponseDTO>
    func logout(refreshToken: String) -> Single<GenericResponse<EmptyResponseData>>
    func withdraw(refreshToken: String) -> Single<GenericResponse<EmptyResponseData>>
}

struct EmptyResponseData: Codable {}

final class AuthAPI: AuthAPIProtocol {
    private func request<T: Decodable, B: Encodable>(
        _ url: String,
        method: Alamofire.HTTPMethod,
        header: HTTPHeaders,
        body: B
    ) -> Single<T> {
        return Single.create { single in
            let req = AF.request(
                url,
                method: method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: header
            )
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value):
                        single(.success(value))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    // 소셜 로그인
    func socialLogin(request: SocialLoginRequestDTO) -> Single<SocialLoginResponseDTO> {
        let url = NetworkDefine.AuthAPI.snsLogin.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        
        // 토큰이 있으면 추가 (재로그인 케이스)
        if let token = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return self.request(url, method: .post, header: headers, body: request)
    }
    
    // 로그아웃
    func logout(refreshToken: String) -> Single<GenericResponse<EmptyResponseData>> {
        let url = NetworkDefine.AuthAPI.logout.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["jwt-token"] = refreshToken
        
        if let token = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        // Body가 없는 경우 EmptyBody 사용
        struct EmptyBody: Encodable {}
        
        return self.request(url, method: .post, header: headers, body: EmptyBody())
    }
    
    // 탈퇴하기
    func withdraw(refreshToken: String) -> Single<GenericResponse<EmptyResponseData>> {
        let url = NetworkDefine.AuthAPI.withdraw.url

        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        if !refreshToken.isEmpty {
            headers["jwt-token"] = refreshToken
        }
        // 리프레시 토큰이 없는 경우 액세스 토큰으로 인증 (백엔드 필터가 두 헤더 모두 허용)
        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        struct WithdrawBody: Encodable {
            let password: String
        }

        return self.request(url, method: .post, header: headers, body: WithdrawBody(password: ""))
    }
}

