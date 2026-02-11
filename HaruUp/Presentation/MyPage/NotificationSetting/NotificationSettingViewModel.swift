//
//  NotificationSettingViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 1/16/26.
//

import Foundation
import RxSwift
import RxCocoa
import UserNotifications

final class NotificationSettingViewModel {
    // Input
    struct Input {
        let viewWillAppear: Observable<Void>
        let switchToggled: Observable<Bool>
    }
    
    // Output
    struct Output {
        let initialSwitchState: Driver<Bool>
        let shouldOpenSettings: Driver<Void>
    }
    
    private let settingKey = "isPushNotificationEnabled"
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 1. 화면 진입 시 실제 iOS 시스템 알림 권한 상태 확인
        let systemNotificationStatus = input.viewWillAppear
            .flatMap { _ -> Observable<Bool> in
                return Observable.create { observer in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        let isAuthorized = settings.authorizationStatus == .authorized
                        observer.onNext(isAuthorized)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .share(replay: 1)
        
        // 2. 시스템 권한 상태를 UserDefaults에 동기화
        systemNotificationStatus
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                UserDefaults.standard.set(isEnabled, forKey: self.settingKey)
                print("✅ 시스템 알림 권한 상태 동기화: \(isEnabled)")
            })
            .disposed(by: disposeBag)
        
        // 3. 초기 스위치 상태
        let initialState = systemNotificationStatus
            .asDriver(onErrorJustReturn: false)
        
        // 4. 스위치 탭 시 설정 앱으로 이동
        let shouldOpenSettings = input.switchToggled
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        return Output(
            initialSwitchState: initialState,
            shouldOpenSettings: shouldOpenSettings
        )
    }
}
