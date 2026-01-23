//
//  Service.swift
//  HaruUp
//
//  Created by 조영현 on 12/25/25.
//

import Foundation
import RxSwift
import Alamofire

class Service {
    /// JSON Body 요청
    func request<T: Decodable, B: Encodable>(_ url: String, method: Alamofire.HTTPMethod, header: HTTPHeaders, body: B) -> Single<T> {
        
        return Single.create { single in
            let req = AF.request(url, method: method, parameters: body, encoder: JSONParameterEncoder.default, headers: header)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value): single(.success(value))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    /// Query 요청
    func request<T: Decodable, Q: Encodable>(_ url: String, method: Alamofire.HTTPMethod, header: HTTPHeaders, query: Q) -> Single<T> {

        return Single.create { single in
            let req = AF.request(url, method: method, parameters: query, encoder: URLEncodedFormParameterEncoder(destination: .queryString), headers: header)
            .validate()
            .responseDecodable(of: T.self) { resp in
                debugPrint(resp)
                switch resp.result {
                case .success(let value):
                    single(.success(value))
                case .failure(let error):
                    if error.isExplicitlyCancelledError {
                        print("요청이 취소되었습니다. (에러 처리 무시)")
                        return
                    }
                    
                    // 진짜 에러인 경우에만 로그 찍고 failure 전달
                    if let data = resp.data,
                       let body = String(data: data, encoding: .utf8) {
                        print("Server error body:", body)
                    }
                    single(.failure(error))
                }
            }

            return Disposables.create { req.cancel() }
        }
    }
    
    func request<T: Decodable>(_ url: String, method: Alamofire.HTTPMethod, header: HTTPHeaders) -> Single<T> {
        
        return Single.create { single in
            let req = AF.request(url, method: method, headers: header)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value): single(.success(value))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
}
