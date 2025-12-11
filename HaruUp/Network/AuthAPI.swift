//
//  AuthAPI.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation
import RxSwift

protocol AuthAPIProtocol {
    func socialLogin(request: SocialLoginRequest) -> Single<SocialLoginResponse>
}

final class AuthAPI: AuthAPIProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func socialLogin(request: SocialLoginRequest) -> Single<SocialLoginResponse> {
        // 소셜 로그인 요청 (loginType, snsId, email, name, token)
        var parameters: [String: Any] = [
            "loginType": request.provider.rawValue,
            "snsId": request.snsUserId,
            "email": request.email ?? "",
            "name": request.name ?? "",
            "token": request.accessToken
        ]
        
        // Apple 로그인인 경우 추가 필드
        if request.provider == .apple {
            if let identityToken = request.identityToken {
                parameters["identityToken"] = identityToken
            }
            if let authorizationCode = request.authorizationCode {
                parameters["authorizationCode"] = authorizationCode
            }
            if let userIdentifier = request.userIdentifier {
                parameters["userIdentifier"] = userIdentifier
            }
            if let nonce = request.nonce {
                parameters["nonce"] = nonce
            }
        }
        
        return apiClient.request(
            endpoint: "/member/auth/sns-login",
            method: .POST,
            parameters: parameters
        )
    }
}
