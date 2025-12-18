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
        
        // Body가 없는 경우 EmptyBody 사용
        struct EmptyBody: Encodable {}
        
        return self.request(url, method: .post, header: headers, body: EmptyBody())
    }
}












//final class AuthAPI: AuthAPIProtocol {
//    private let apiClient: APIClient
//
//    init(apiClient: APIClient = APIClient.shared) {
//        self.apiClient = apiClient
//    }
//
//    func socialLogin(request: SocialLoginRequest) -> Single<SocialLoginResponse> {
//        // 소셜 로그인 요청 (loginType, snsId, email, name, token)
//        var parameters: [String: Any] = [
//            "loginType": request.provider.rawValue,
//            "snsId": request.snsUserId,
//            "email": request.email ?? "",
//            "name": request.name ?? "",
//            "token": request.accessToken
//        ]
//
//        // Apple 로그인인 경우 추가 필드
//        if request.provider == .apple {
//            if let identityToken = request.identityToken {
//                parameters["identityToken"] = identityToken
//            }
//            if let authorizationCode = request.authorizationCode {
//                parameters["authorizationCode"] = authorizationCode
//            }
//            if let userIdentifier = request.userIdentifier {
//                parameters["userIdentifier"] = userIdentifier
//            }
//            if let nonce = request.nonce {
//                parameters["nonce"] = nonce
//            }
//        }
//
//        return apiClient.request(
//            endpoint: "/member/auth/sns-login",
//            method: .POST,
//            parameters: parameters
//        )
//    }
//
//    func logout(refreshToken: String) -> Single<GenericResponse<EmptyResponseData>> {
//        let headers = ["jwt-token": refreshToken]
//        return apiClient.request(
//            endpoint: "/member/auth/logout",
//            method: .POST,
//            parameters: nil,
//            headers: headers
//        )
//    }
//}
