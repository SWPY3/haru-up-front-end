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
        let viewWillAppear: Observable<Void>
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
    
    private let curationDataRelay = BehaviorRelay<CurationData>(value: CurationData())
    
    private let authAPI: AuthAPIProtocol
    private let tokenStorage: TokenStorageService
    private let disposeBag = DisposeBag()
    private let interestsService: InterestsService
    
    init(
        curationData: CurationData,
        authAPI: AuthAPIProtocol = AuthAPI(),
        tokenStorage: TokenStorageService = .shared,
        interestsService: InterestsService = .shared
    ) {
        if let localData = tokenStorage.getCurationData() {
            self.curationDataRelay.accept(localData)
        } else {
            self.curationDataRelay.accept(curationData)
        }
        
        self.authAPI = authAPI
        self.tokenStorage = tokenStorage
        self.interestsService = interestsService
    }
    
    func transform(input: Input) -> Output {
        // 1. 화면 진입 시 서버 데이터 요청 (viewDidLoad, viewWillAppear 둘 다)
        Observable.merge(input.viewDidLoad, input.viewWillAppear)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if let localData = self.tokenStorage.getCurationData() {
                    self.curationDataRelay.accept(localData)
                }
                
                self.fetchServerData()
            })
            .disposed(by: disposeBag)
        
        
        let version = Driver.just("버전.v.1.0.0")
        
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
            curationData: curationDataRelay.asDriver(),
            appVersion: version,
            showLogoutAlert: showLogoutAlert,
            showWithdrawFirstAlert: showWithdrawFirstAlert,
            showWithdrawSuccessAlert: showWithdrawSuccessRelay.asSignal(),
            logoutSuccess: logoutSuccessRelay.asSignal(),
            withdrawSuccess: withdrawSuccessRelay.asSignal(),
            errorMessage: errorRelay.asSignal()
        )
    }
    
    // MARK: - API Fetching (서버 데이터 가져오기)
    private func fetchServerData() {
        // 1. 관심사 데이터 가져오기
        interestsService.fetchMemberInterests()
            .subscribe(onNext: { [weak self] interests in
                guard let self = self else { return }
                
                // 현재 데이터 복사 (닉네임 등 다른 정보 유지를 위해)
                var currentData = self.curationDataRelay.value
                
                // 가장 최근(첫 번째) 관심사 데이터 사용
                if let latest = interests.first {
                    let path = latest.directFullPath
                    // path 예시: ["체력관리 및 운동", "헬스", "근력 키우기"]
                    
                    // [0] 1단계: 관심사
                    if path.indices.contains(0) {
                        // ID는 모르므로 0, 이름은 path[0] 사용 (아이콘 매핑용)
                        currentData.interest = InterestData(id: 0, name: path[0])
                    }
                    
                    // [1] 2단계: 세부 관심사
                    if path.indices.contains(1) {
                        currentData.interestDetail = InterestData(id: 0, name: path[1])
                    }
                    
                    // [2] 3단계: 목표
                    if path.indices.contains(2) {
                        // API가 주는 interestId는 '목표'의 ID입니다.
                        currentData.goal = InterestData(id: latest.interestId, name: path[2])
                    }
                    
                    // (선택사항) 최신 데이터를 로컬에도 업데이트해두면 다음 앱 실행 시 더 빠름
                    // self.tokenStorage.saveCurationData(currentData)
                }
                
                // UI 업데이트 트리거
                self.curationDataRelay.accept(currentData)
                
            }, onError: { error in
                print("⚠️ 마이페이지 관심사 로드 실패: \(error)")
                // 에러 발생 시 기존 로컬 데이터가 유지됨
            })
            .disposed(by: disposeBag)
        
        // 2. (추후 구현) 프로필 정보(닉네임, 직업)도 여기서 fetchProfile()을 호출하여 currentData를 업데이트해야 함
    }
    
    // 로그아웃 실행
    func performLogout() -> Single<Void> {
        guard let refreshToken = tokenStorage.getRefreshToken() else {
            return Single.error(NSError(domain: "MyPageViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "리프레시 토큰을 찾을 수 없습니다."]))
        }
        
        return authAPI.logout(refreshToken: refreshToken)
            .map { response in
                print("response : \(response)")
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
