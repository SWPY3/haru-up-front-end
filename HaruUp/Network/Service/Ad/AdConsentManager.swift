//
//  AdConsentManager.swift
//  HaruUp
//
//  Created by 하다현 on 8/9/26.
//

import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency
import UIKit

final class AdConsentManager {
    static let shared = AdConsentManager()
    private init() {}

    private var isMobileAdsStarted = false

    /// 첫 화면의 viewDidAppear에서 이 함수 하나만 호출하면 됩니다.
    func requestConsentAndInitializeAds(from viewController: UIViewController,
                                         completion: @escaping () -> Void) {
        let parameters = RequestParameters()

        // ① 동의 정보 업데이트 요청 (앱 실행할 때마다 호출)
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            guard let self else { return }
            if let error {
                print("[AdConsentManager] 동의 정보 업데이트 실패: \(error.localizedDescription)")
            }

            // ② 필요한 경우에만 동의 폼을 자동으로 띄워줌 (EEA/영국 사용자 등)
            ConsentForm.loadAndPresentIfRequired(from: viewController) { formError in
                if let formError {
                    print("[AdConsentManager] 동의 폼 표시 실패: \(formError.localizedDescription)")
                }

                // ③ 동의 절차가 끝난 뒤 ATT 권한 요청
                self.requestTrackingAuthorization {
                    // ④ SDK 초기화 확정 + ⑤ 광고 로드 가능 여부 콜백
                    self.startGoogleMobileAdsSDK(completion: completion)
                }
            }
        }
    }

    private func requestTrackingAuthorization(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async { completion() }
            }
        } else {
            completion()
        }
    }

    private func startGoogleMobileAdsSDK(completion: @escaping () -> Void) {
        guard !isMobileAdsStarted else {
            completion()
            return
        }
        // 사용자가 동의하지 않아 광고를 요청할 수 없는 상태면 여기서 걸러짐
        guard ConsentInformation.shared.canRequestAds else {
            completion()
            return
        }
        isMobileAdsStarted = true
        MobileAds.shared.start { _ in
            DispatchQueue.main.async { completion() }
        }
    }
}
