//
//  NotificationSettingViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 1/16/26.
//

import Foundation
import RxSwift
import RxCocoa


final class NotificationSettingViewModel {
    // Input
    struct Input {
        let viewWillAppear: Observable<Void>
        let switchToggled: Observable<Bool>
    }
    
    // Output
    struct Output {
        let initialSwitchState: Driver<Bool>
        let settingSaved: Driver<Bool>
    }
    
    private let settingKey = "isPushNotificationEnabled"
    
    func transform(input: Input) -> Output {
        // 1. 초기 스위치 상태 (저장된 값 불러오기)
        let initialState = input.viewWillAppear
            .map { [weak self] _ in
                UserDefaults.standard.bool(forKey: self?.settingKey ?? "isPushNotificationEnabled")
            }
            .asDriver(onErrorJustReturn: true) // 기본값 true
        
        // 2. 스위치 변경 시 저장
        let settingSaved = input.switchToggled
            .do(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                UserDefaults.standard.set(isEnabled, forKey: self.settingKey)
                print("✅ 알림 설정 저장됨: \(isEnabled)")
            })
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            initialSwitchState: initialState,
            settingSaved: settingSaved
        )
    }
}
