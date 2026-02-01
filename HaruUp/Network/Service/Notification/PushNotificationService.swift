//
//  PushNotificationService.swift
//  HaruUp
//
//  Created by 하다현 on 1/28/26.
//

import RxSwift
import RxCocoa
import FirebaseMessaging
import Alamofire
import UIKit

final class PushNotificationService {
    static let shared = PushNotificationService()
    
    // FCM 토큰 관리
    private let fcmTokenRelay = BehaviorRelay<String?>(value: nil)
    
    // 푸시 데이터 관리
    private let pushDataRelay = PublishRelay<[AnyHashable: Any]>()
    
    private let disposeBag = DisposeBag()// 외부에서 구독 가능한 Observable
    
    private var commonHeaders: HTTPHeaders {
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let accessToken = TokenStorageService.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        return headers
    }
    
    var fcmToken: Observable<String?> {
        return fcmTokenRelay.asObservable()
    }
    
    var pushData: Observable<[AnyHashable: Any]> {
        return pushDataRelay.asObservable()
    }
    
    private init() {
        // 저장된 토큰이 있으면 로드
        if let savedToken = UserDefaults.standard.string(forKey: "fcmToken") {
            fcmTokenRelay.accept(savedToken)
        }
    }
    
    // FCM 토큰 업데이트
    func updateFCMToken(_ token: String) {
        fcmTokenRelay.accept(token)
        UserDefaults.standard.set(token, forKey: "fcmToken")
    }
    
    // 푸시 데이터 수신
    func receivePushData(_ data: [AnyHashable: Any]) {
        pushDataRelay.accept(data)
    }
    
    // 현재 FCM 토큰 가져오기
    func getCurrentToken() -> String? {
        return Messaging.messaging().fcmToken
    }
    
    // 서버에 FCM 토큰 전송 (NetworkService 연동 필요)
    func sendTokenToServer(memberId: String) -> Observable<Void> {
        guard let token = getCurrentToken() else {
            return .error(NSError(domain: "FCMToken", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "FCM 토큰이 없습니다"]))
        }
        
        print("서버에 FCM 토큰 전송: \(token)")
        
        guard let memberIdInt = Int(memberId) else {
            return .error(NSError(domain: "InvalidMemberId", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "memberId가 유효하지 않습니다"]))
        }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        let platform = "IOS"
        
        let parameters: [String: Any] = [
            "memberId": memberIdInt,
            "deviceId": deviceId,
            "platform": platform,
            "token": token
        ]
        
        return Observable.create { observer in
            let url = NetworkDefine.NotificationAPI.registerToken.url
            
            print("📡 FCM 토큰 등록 요청: \(url)")
            print("📦 파라미터: \(parameters)")
            
            let request = AF.request(
                url,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: self.commonHeaders
            )
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        print("✅ FCM 토큰 서버 등록 성공")
                        observer.onNext(())
                        observer.onCompleted()
                        
                    case .failure(let error):
                        print("❌ FCM 토큰 서버 등록 실패: \(error)")
                        if let data = response.data, let serverMessage = String(data: data, encoding: .utf8) {
                            print("📝 [서버 에러 사유]: \(serverMessage)")
                        }
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func sendTokenToServerIfLoggedIn() -> Observable<Void> {
        guard let memberId = TokenStorageService.shared.getMemberId() else {
            print("⚠️ memberId가 없어서 FCM 토큰을 전송하지 않습니다")
            return .empty()
        }
        
        return sendTokenToServer(memberId: memberId)
    }
}
