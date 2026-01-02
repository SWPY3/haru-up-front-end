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
            
            AF.request(url, method: .get, parameters: parameters, headers: self.commonHeaders)
                .validate()
                .responseDecodable(of: InterestAPIResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        let details = result.interests.map { InterestDetail(from: $0) }
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
}

struct InterestAPIResponse: Decodable {
    let interests: [InterestData]
    let totalCount: Int
}
