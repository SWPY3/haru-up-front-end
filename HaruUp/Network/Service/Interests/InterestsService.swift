//
//  InterestsService.swift
//  HaruUp
//
//  Created by 조영현 on 12/25/25.
//

import Foundation
import RxSwift
import Alamofire

final class InterestsService: Service {
    
    static let shared = InterestsService()
    
    private var commonHeaders: HTTPHeaders {
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let refreshToken = TokenStorageService.shared.getRefreshToken() {
            headers["Authorization"] = "Bearer \(refreshToken)"
        }
        return headers
    }
    
    override init() {}
    
    // MARK: - Fetch Interests
    // 관심사 목록 가져오기
    func fetchInterests() -> Single<Interests.InterestsDTO> {
        let url: String = NetworkDefine.InterestsAPI.member.url
        return request(url, method: Alamofire.HTTPMethod.get, header: self.commonHeaders)
    }
    
    func fetchInterest() -> Observable<[Interest]> {
        return Observable.create { observer in
            let url = NetworkDefine.InterestAPI.getInterestList.url
            
            AF.request(url, method: .get, headers: self.commonHeaders)
                .validate()
                .responseDecodable(of: InterestAPIResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        let interests = result.interests.map { Interest(from: $0) }
                        observer.onNext(interests)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Fetch Interest Details
    /// 세부 관심사 목록 가져오기
    func fetchInterestDetails(parentId: Int) -> Observable<[InterestDetail]> {
        return Observable.create { observer in
            let url = NetworkDefine.InterestAPI.getInterestDetail(parentId: parentId).url
            let parameters: [String: Any] = ["parentId": parentId]
            
            print("📡 세부 관심사 요청 - Parent ID: \(parentId)")
            
            AF.request(url, method: .get, parameters: parameters, headers: self.commonHeaders)
                .validate()
                .responseDecodable(of: InterestAPIResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        let details = result.interests.map { InterestDetail(from: $0) }
                        print("📥 받은 세부 관심사 목록: \(result)")
                        observer.onNext(details)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Fetch Goals
    /// 목표 목록 가져오기
    func fetchGoals(parentId: Int) -> Observable<[Goal]> {
        return Observable.create { observer in
            let url = NetworkDefine.InterestAPI.getGoalList(parentId: parentId).url
            let parameters: [String: Any] = ["parentId": parentId]
            
            AF.request(url, method: .get, parameters: parameters, headers: self.commonHeaders)
                .validate()
                .responseDecodable(of: InterestAPIResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        let goals = result.interests.map { Goal(from: $0) }
                        observer.onNext(goals)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func updateMemberInterest(memberInterestId: Int, interestId: Int, directFullPath: [String]) -> Single<Void> {
        return Single.create { single in
            let urlString = "\(NetworkDefine.InterestsAPI.member.url)/\(memberInterestId)"
            
            guard let accessToken = TokenStorageService.shared.getAccessToken() else {
                let error = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Access Token Missing"])
                single(.failure(error))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            let parameters: [String: Any] = [
                "interestId": interestId,
                "directFullPath": directFullPath
            ]
            
            print("📡 관심사 수정 요청: \(urlString)")
            print("📦 파라미터: \(parameters)")
            
            
            let request = AF.request(
                urlString,
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        single(.success(()))
                        print("📥 관심사 수정 응답: \(value)")
                    case .failure(let error):
                        print("❌ 요청 실패: \(error.localizedDescription)")
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func validateGoalInput(text: String) -> Single<Bool> {
        return Single.create { single in
            let url = NetworkDefine.InterestAPI.validation.url
            
            // 헤더 설정 (content-type, jwt-token: refreshToken)
            var headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]
            if let refreshToken = TokenStorageService.shared.getRefreshToken() {
                headers.add(name: "jwt-token", value: refreshToken)
            }
            
            let parameters: [String: Any] = [
                "interest": text
            ]
            
            print("📡 유효성 검사 요청: \(text)")
            
            let request = AF.request(
                url,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        // 응답 파싱: { "success": true, "data": { "isValid": true, ... } }
                        print("📥 유효성 검사 응답 Raw Data: \(value)")
                        if let json = value as? [String: Any],
                           let data = json["data"] as? [String: Any],
                           let isValid = data["isValid"] as? Bool {
                            if !isValid {
                                let reason = data["reason"] as? String ?? "이유 없음"
                                print("❌ 서버 판정: 유효하지 않음 (사유: \(reason))")
                            } else {
                                print("✅ 서버 판정: 유효함")
                            }
                            single(.success(isValid))
                        } else {
                            print("⚠️ JSON 파싱 실패: 예상한 구조(data.isValid)가 아님")
                            // 파싱 실패 시 기본값 false
                            single(.success(false))
                        }
                        
                    case .failure(let error):
                        print("❌ 유효성 검사 API 실패: \(error)")
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
    
}

struct InterestAPIResponse: Decodable {
    let interests: [InterestData]
    let totalCount: Int
}
