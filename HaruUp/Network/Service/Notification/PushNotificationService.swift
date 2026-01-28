//
//  PushNotificationService.swift
//  HaruUp
//
//  Created by 하다현 on 1/28/26.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseMessaging


final class PushNotificationService {
    static let shared = PushNotificationService()
    
    // FCM 토큰 관리
    private let fcmTokenRelay = BehaviorRelay<String?>(value: nil)
    
    // 푸시 데이터 관리
    private let pushDataRelay = PublishRelay<[AnyHashable: Any]>()
    
    private let disposeBag = DisposeBag()// 외부에서 구독 가능한 Observable
    
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
    func sendTokenToServer() -> Observable<Void> {
        guard let token = getCurrentToken() else {
            return .error(NSError(domain: "FCMToken", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "FCM 토큰이 없습니다"]))
        }
        
        // TODO: 실제 네트워크 서비스 연동
        // return networkService.updateFCMToken(token)
        
        print("서버에 FCM 토큰 전송: \(token)")
        return .just(())
    }
}
