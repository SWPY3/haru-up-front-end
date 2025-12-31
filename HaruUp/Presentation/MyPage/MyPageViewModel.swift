//
//  MyPageViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        // 버튼 5개에 대한 이벤트
        let editInterestTapped: ControlEvent<Void>
        let feedbackTapped: ControlEvent<Void>   // 의견남기기
        let inquiryTapped: ControlEvent<Void>    // 문의하기
        let logoutTapped: ControlEvent<Void>
        let withdrawTapped: ControlEvent<Void>
    }
    
    struct Output {
        let curationData: Driver<CurationData>
        let appVersion: Driver<String>
        let showLogoutAlert: Signal<Void>
        let showWithdrawFirstAlert: Signal<Void>
        let showWithdrawSuccessAlert: Signal<Void>
        let logoutSuccess: Signal<Void>
        let withdrawSuccess: Signal<Void>
        let errorMessage: Signal<String>
    }
    
    private let curationData: CurationData
    private let authAPI: AuthAPIProtocol
    private let tokenStorage: TokenStorageService
    private let disposeBag = DisposeBag()
    
    init(
        curationData: CurationData,
        authAPI: AuthAPIProtocol = AuthAPI(),
        tokenStorage: TokenStorageService = .shared
    ) {
        self.curationData = curationData
        self.authAPI = authAPI
        self.tokenStorage = tokenStorage
    }
    
    func transform(input: Input) -> Output {
        let curationDataDriver = input.viewDidLoad
            .map { [weak self] _ in
                // 앱을 껐다 켜도 여기서 다시 불러오기 때문에 데이터가 보입니다.
                return self?.tokenStorage.getCurationData() ?? CurationData()
            }
            .asDriver(onErrorJustReturn: CurationData())
        
        let version = Driver.just("버전.v.16.2")
        
        // 로그아웃 Alert 표시
        let showLogoutAlert = input.logoutTapped
            .asSignal()
        
        // 탈퇴 첫 번째 Alert 표시
        let showWithdrawFirstAlert = input.withdrawTapped
            .asSignal()
        
        // 로그아웃 처리
        let logoutSuccessRelay = PublishRelay<Void>()
        let withdrawSuccessRelay = PublishRelay<Void>()
        let showWithdrawSuccessRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        
        // 로그아웃 API 호출 (외부에서 Alert 확인 후 호출)
        // ViewModel에서 직접 처리하지 않고, ViewController에서 Alert 확인 후 호출하도록
        
        return Output(
            curationData: curationDataDriver,
            appVersion: version,
            showLogoutAlert: showLogoutAlert,
            showWithdrawFirstAlert: showWithdrawFirstAlert,
            showWithdrawSuccessAlert: showWithdrawSuccessRelay.asSignal(),
            logoutSuccess: logoutSuccessRelay.asSignal(),
            withdrawSuccess: withdrawSuccessRelay.asSignal(),
            errorMessage: errorRelay.asSignal()
        )
    }
    
    // 로그아웃 실행
    func performLogout() -> Single<Void> {
        guard let refreshToken = tokenStorage.getRefreshToken() else {
            return Single.error(NSError(domain: "MyPageViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "리프레시 토큰을 찾을 수 없습니다."]))
        }
        
        return authAPI.logout(refreshToken: refreshToken)
            .map { response in
                if response.success {
                    self.tokenStorage.clearForLogout()
                } else {
                    throw NSError(domain: "MyPageViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message ?? "로그아웃에 실패했습니다."])
                }
            }
    }
    
    // 탈퇴 실행
    func performWithdraw() -> Single<Void> {
        guard let refreshToken = tokenStorage.getRefreshToken() else {
            return Single.error(NSError(domain: "MyPageViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "리프레시 토큰을 찾을 수 없습니다."]))
        }
        
        return authAPI.withdraw(refreshToken: refreshToken)
            .map { response in
                if response.success {
                    self.tokenStorage.clearForWithdraw()
                } else {
                    throw NSError(domain: "MyPageViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message ?? "탈퇴에 실패했습니다."])
                }
            }
    }
}
