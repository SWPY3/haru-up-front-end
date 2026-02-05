//
//  AppDelegate.swift
//  HaruUp
//
//  Created by 하다현 on 11/26/25.
//

import UIKit
import RxSwift
import CoreData
import KakaoSDKCommon
import KakaoSDKAuth
import NidThirdPartyLogin
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // App 최초 실행 여부
        TokenStorageService.shared.checkFirstLaunch()
        
        // Naver 로그인 초기화
        NidOAuth.shared.initialize(
            appName: NaverLoginConfig.appName,
            clientId: NaverLoginConfig.clientId,
            clientSecret: NaverLoginConfig.clientSecret,
            urlScheme: NaverLoginConfig.urlScheme
        )
        
        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
        
        
        // 네이티브 앱 키로 Kakao SDK 초기화
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else { // KaKao native app key를 Info에 저장하여 구현
            return true
        }
        
        KakaoSDK.initSDK(appKey: appKey)
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // FCM Delegate 설정
        Messaging.messaging().delegate = self
        
        // 푸시 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                print("푸시 권한 허용: \(granted)")
                if let error = error {
                    print("푸시 권한 에러: \(error)")
                }
            }
        )
        
        // APNs 등록
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    // APNs 토큰 등록 성공
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("========================================")
        print("✅✅✅ APNs 토큰 수신 성공! ✅✅✅")
        print("========================================")
        // 토큰을 16진수 문자열로 변환
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNs Device Token: \(token)")
        
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs 토큰을 Firebase에 전달 완료")
    }
    
    // APNs 토큰 등록 실패
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs 등록 실패: \(error.localizedDescription)")
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "HaruUp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 Foreground 상태일 때 푸시 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Foreground 푸시 수신: \(userInfo)")
        
        // 푸시 데이터 전달
        PushNotificationService.shared.receivePushData(userInfo)
        
        // iOS 14 이상
        completionHandler([.banner, .sound, .badge])
    }
    
    // 푸시 알림 탭했을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("푸시 탭: \(userInfo)")
        
        PushNotificationService.shared.receivePushData(userInfo)
        // Coordinator를 통해 라우팅 처리
        // 예: AppCoordinator에 푸시 데이터 전달
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // FCM 토큰 갱신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM 토큰: \(fcmToken ?? "")")
        print("========================================")
        print("🔥🔥🔥 FCM 토큰 수신! 🔥🔥🔥")
        print("========================================")
//        print(fcmToken ?? "❌ 토큰이 없습니다")
        print("========================================")
        
        guard let token = fcmToken else {
            print("⚠️ FCM 토큰이 nil입니다")
            return
        }
        
        PushNotificationService.shared.updateFCMToken(token)
        
        // 로그인 상태이고, 토큰이 변경되었을 때만 서버에 전송
        let savedToken = UserDefaults.standard.string(forKey: "fcmTokenSentToServer")
        
        if savedToken != token, TokenStorageService.shared.getMemberId() != nil {
            print("🔄 FCM 토큰 변경 감지 - 서버에 재등록")
            PushNotificationService.shared.sendTokenToServerIfLoggedIn()
                .subscribe(
                    onNext: {
                        // 성공 시 서버에 전송한 토큰 저장
                        print("✅ FCM 토큰 서버 재등록 성공")
                        UserDefaults.standard.set(token, forKey: "fcmTokenSentToServer")
                    },
                    onError: { error in
                        print("FCM 토큰 재등록 실패: \(error)")
                    }
                )
                .disposed(by: self.disposeBag)
        }
    }
}
