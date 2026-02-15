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
    private let authService: AuthService
    private let jobService: JobService
    private let tokenStorage: TokenStorageService
    private let disposeBag = DisposeBag()
    private let interestsService: InterestsService
    
    init(
        curationData: CurationData,
        authAPI: AuthAPIProtocol = AuthAPI(),
        authService: AuthService = AuthService(),
        jobService: JobService = .shared,
        tokenStorage: TokenStorageService = .shared,
        interestsService: InterestsService = .shared
    ) {
        self.authAPI = authAPI
        self.authService = authService
        self.jobService = jobService
        self.tokenStorage = tokenStorage
        self.interestsService = interestsService
        
        self.updateUIFromLocalStorage()
    }
    
    func transform(input: Input) -> Output {
        // 1. 화면 진입 시 서버 데이터 요청 (viewDidLoad, viewWillAppear 둘 다)
        Observable.merge(input.viewDidLoad, input.viewWillAppear)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.fetchAndSaveServerData()
            })
            .disposed(by: disposeBag)
        
        let version = Driver.just("버전.v.1.0.6")
        
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
    
    // MARK: - 로직 1: 로컬 스토리지 -> UI 반영
    private func updateUIFromLocalStorage() {
        var data = CurationData() // 빈 객체 시작
        
        // [프로필] 로컬에서 가져오기
        let profile = tokenStorage.getProfile()
        data.nickname = profile.nickname
        data.characterId = profile.characterId
        if profile.jobId != 0 {
            data.job = Job(id: profile.jobId, jobName: profile.jobName ?? "")
        }
        if profile.jobDetailId != 0 {
            data.jobDetail = JobDetail(id: profile.jobDetailId, jobDetailName: profile.jobDetailName ?? "")
        }
        
        // [관심사] 로컬에서 가져오기
        if let interests = tokenStorage.getMemberInterests(), let first = interests.first {
            let path = first.directFullPath // ["운동", "헬스", "다이어트"]
            
            // 이름만 가지고 UI용 객체 생성 (ID는 없어도 표시엔 문제 없음)
            if path.indices.contains(0) { data.interest = InterestData(id: 0, name: path[0]) }
            if path.indices.contains(1) { data.interestDetail = InterestData(id: 0, name: path[1]) }
            if path.indices.contains(2) { data.goal = InterestData(id: first.interestId, name: path[2]) }
        }
        
        // UI 갱신
        curationDataRelay.accept(data)
    }
    
    // MARK: - Logic: API -> Local Storage
    private func fetchAndSaveServerData() {
        // 1. 프로필 & 관심사 API 호출
        Single.zip(
            authService.fetchProfile(),
            authService.fetchMemberInterests()
        )
        .flatMap { [weak self] (profile, interests) -> Single<(String?, String?, ProfileData, [MemberInterestDTO])> in
            guard let self = self else { return .just((nil, nil, profile, interests)) }
            
            // 직업 이름 조회 (ID -> Name)
            guard let jobId = profile.jobId, jobId != 0 else {
                return .just((nil, nil, profile, interests))
            }
            let jobDetailId = profile.jobDetailId ?? 0
            
            // 직업 이름을 가져오는 API 호출
            return self.fetchJobNames(jobId: jobId, jobDetailId: jobDetailId)
                .map { (jobName, detailName) in
                    return (jobName, detailName, profile, interests)
                }
        }
        .subscribe(onSuccess: { [weak self] (jobName, jobDetailName, profile, interests) in
            guard let self = self else { return }
            
            let isSelfEmployed = (jobName == "자영업")
            let finalJobDetailId = isSelfEmployed ? 0 : profile.jobDetailId
            
            // 2. 프로필 정보 로컬 저장 (이름 포함)
            self.tokenStorage.saveProfile(
                nickname: profile.nickname,
                characterId: profile.characterId,
                jobId: profile.jobId,
                jobName: jobName,           // 찾아온 직업 이름 저장
                jobDetailId: finalJobDetailId,
                jobDetailName: jobDetailName // 찾아온 상세 직업 이름 저장
            )
            
            // 3. 관심사 정보 로컬 저장
            self.tokenStorage.saveMemberInterests(interests)
            
            // 3. 저장된 최신 데이터로 화면 갱신
            self.updateUIFromLocalStorage()
            
            print("✅ [MyPageVM] 서버 데이터 동기화 및 로컬 저장 완료")
            
        }, onFailure: { error in
            print("⚠️ [MyPageVM] 데이터 동기화 실패: \(error)")
        })
        .disposed(by: disposeBag)
    }
    
    // 직업 ID -> 직업 이름 변환 로직 (기존과 동일)
    private func fetchJobNames(jobId: Int, jobDetailId: Int) -> Single<(String?, String?)> {
        return jobService.fetchJobs()
            .take(1)
            .asSingle()
            .flatMap { [weak self] jobs -> Single<(String?, String?)> in
                guard let self = self else { return .just((nil, nil)) }
                
                guard let myJob = jobs.first(where: { $0.id == jobId }) else {
                    return .just((nil, nil))
                }
                let jobName = myJob.jobName
                
                if jobName == "자영업" {
                    return .just((jobName, nil))
                }
                
                return self.jobService.fetchJobDetails(jobId: jobId)
                    .take(1)
                    .asSingle()
                    .map { details in
                        let detailName = details.first(where: { $0.id == jobDetailId })?.jobDetailName
                        return (jobName, detailName)
                    }
                    .catchAndReturn((jobName, nil))
            }
            .catchAndReturn((nil, nil))
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
