//
//  ChartService.swift
//  HaruUp
//
//  Created by 하다현 on 1/12/26.
//

import Foundation
import Alamofire
import RxSwift

class ChartService {
    private var commonHeaders: HTTPHeaders {
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let refreshToken = TokenStorageService.shared.getRefreshToken() {
            headers["Authorization"] = "Bearer \(refreshToken)"
        }
        return headers
    }
    
    func fetchPopularRanking(parameters: [String: Any]?) -> Observable<[ChartItem]> {
        return Observable.create { observer in
            let url = NetworkDefine.RankingAPI.popular.url
            
            // 배열 파라미터 인코딩 (key=value&key=value)
            let encoding = URLEncoding(arrayEncoding: .noBrackets)
            
            let request = AF.request(
                url,
                method: .get,
                parameters: parameters,
                encoding: encoding,
                headers: self.commonHeaders
            )
                .validate()
                .responseDecodable(of: RankingResponse.self) { response in // [ChartItem] -> RankingResponse 로 변경
                    switch response.result {
                    case .success(let apiResponse):
                        // success가 true이고 data가 존재할 때만 방출
                        if apiResponse.success, let data = apiResponse.data {
                            observer.onNext(data)
                            observer.onCompleted()
                        } else {
                            // 서버에서 success: false로 온 경우 에러 처리
                            let message = apiResponse.errorMessage ?? "Unknown Error"
                            let error = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
                            observer.onError(error)
                        }
                        
                    case .failure(let error):
                        print("Network Error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
