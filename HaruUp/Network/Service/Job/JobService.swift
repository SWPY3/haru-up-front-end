//
//  JobService.swift
//  HaruUp
//
//  Created by 하다현 on 1/1/26.
//

import Foundation
import RxSwift
import Alamofire

final class JobService {
    static let shared = JobService() // Singleton 또는 DI 주입 권장
    private init() {}
    
    // 1. 직업 목록 조회
    func fetchJobs() -> Observable<[Job]> {
        let url = NetworkDefine.JobAPI.getJobList.url
        return request(url: url)
    }
    
    // 2. 세부 직무 목록 조회
    func fetchJobDetails(jobId: Int) -> Observable<[JobDetail]> {
        let url = NetworkDefine.JobAPI.getJobDetailList(jobId: jobId).url
        // GET 방식 파라미터 전달
        let parameters: [String: Any] = ["jobId": jobId]
        return request(url: url, parameters: parameters)
    }
    
    // 공통 네트워크 요청 함수 (제네릭)
    private func request<T: Decodable>(url: String, parameters: Parameters? = nil) -> Observable<[T]> {
        return Observable.create { observer in
            
            // 토큰 체크
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                print("❌ refreshToken이 없습니다")
                observer.onError(NSError(domain: "AuthError", code: 401))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "jwt-token": refreshToken
            ]
            
            print("📡 API 요청: \(url)")
            
            let request = AF.request(
                url,
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.default, // GET 요청은 URLEncoding
                headers: headers
            )
            .validate()
            .responseDecodable(of: [T].self) { response in
                switch response.result {
                case .success(let data):
                    print("✅ 조회 성공: \(data.count)건")
                    observer.onNext(data)
                    observer.onCompleted()
                    
                case .failure(let error):
                    print("❌ 요청 실패: \(error.localizedDescription)")
                    // 실패 시 빈 배열 반환 또는 에러 방출 
                    observer.onNext([])
                    observer.onCompleted()
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
