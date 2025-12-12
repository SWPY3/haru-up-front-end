//
//  APIClient.swift
//  HaruUp
//
//  Created by 하다현 on 12/7/25.
//

import Foundation
import RxSwift


enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int, String?)
    case networkError(Error)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .decodingError:
            return "응답 파싱에 실패했습니다."
        case .serverError(let code, let message):
            return message ?? "서버 오류가 발생했습니다. (코드: \(code))"
        case .networkError(let error):
            return error.localizedDescription
        case .unauthorized:
            return "인증에 실패했습니다."
        }
    }
}


final class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        // TODO: 실제 백엔드 URL로 변경
        self.baseURL = "http://223.130.141.179:8080/api"
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self = self,
                  let url = URL(string: "\(self.baseURL)\(endpoint)") else {
                single(.failure(APIError.invalidURL))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            // 기본 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // 추가 헤더
            var allHeaders = headers ?? [:]
            
            // 토큰이 있으면 추가
            if let token = TokenStorageService.shared.getAccessToken() {
                allHeaders["Authorization"] = "Bearer \(token)"
            }
            
            for (key, value) in allHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            // Body 파라미터
            if let parameters = parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    single(.failure(APIError.networkError(error)))
                    return Disposables.create()
                }
            }
            
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    single(.failure(APIError.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    single(.failure(APIError.invalidResponse))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) }
                    if httpResponse.statusCode == 401 {
                        single(.failure(APIError.unauthorized))
                    } else {
                        single(.failure(APIError.serverError(httpResponse.statusCode, errorMessage)))
                    }
                    return
                }
                
                guard let data = data else {
                    single(.failure(APIError.invalidResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(T.self, from: data)
                    single(.success(decoded))
                } catch {
                    print("Decoding error: \(error)")
                    single(.failure(APIError.decodingError))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

