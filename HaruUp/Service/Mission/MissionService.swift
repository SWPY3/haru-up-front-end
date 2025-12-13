//
//  MissionService.swift
//  HaruUp
//
//  Created by 조영현 on 12/11/25.
//

import Foundation
import RxSwift
import Alamofire

protocol MissionServiceProtocol {
    // Home에서 미션 선택창을 띄워야하는지 여부
    func needShowTodayMissionFlow() -> Single<Bool>
    // 미션 선택 완료
    func markTodayMissionSelected()
    // 미션 추천
    func fetchRecommendedMissions(userId: Int, interests: [InterestDTO]) -> Single<MissionRecommendResponseDTO>
}

final class MissionService: MissionServiceProtocol {
    private let defaults = UserDefaults.standard
    
    func request<T: Decodable, B: Encodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders, body: B) -> Single<T> {
        
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
    
    func fetchRecommendedMissions(userId: Int, interests: [InterestDTO]) -> Single<MissionRecommendResponseDTO> {
        
        let url: String = NetworkDefine.MissionAPI.recommend.url
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        headers["Authorization"] = "Bearer" // accessToken
        
        let body: MissionRecommendRequestDTO = .init(userId: userId, interests: interests)
        
        return request(url, method: .post, header: headers, body: body)
    }
}

// MARK: UserDefaults - 미션 선택 여부
extension MissionService {
    private enum Keys {
        static let todayMissionSelectedDate = "todayMissionSelectedDate"
    }
    
    func needShowTodayMissionFlow() -> Single<Bool> {
        let today = Self.todayString()
        let saved = defaults.string(forKey: Keys.todayMissionSelectedDate)
        print("today: \(today)")
        print("saved: \(saved)")
        let needShow = (saved != today)
        return .just(needShow)
    }
    
    func markTodayMissionSelected() {
        let today = Self.todayString()
        defaults.set(today, forKey: Keys.todayMissionSelectedDate)
    }
    
    private static func todayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}

