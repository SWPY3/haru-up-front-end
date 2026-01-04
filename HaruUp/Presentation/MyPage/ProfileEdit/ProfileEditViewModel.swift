//
//  ProfileEditViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/31/25.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class ProfileEditViewModel {
    
    struct Input {
        let nicknameInput: Observable<String>
        let clearButtonTapped: Observable<Void>
        let completeButtonTapped: Observable<Void>
        
        // Job 관련 Input
        let jobButtonTapped: Observable<Void>
        let detailJobButtonTapped: Observable<Void>
        let jobSelected: Observable<DropdownDisplayable>        // 드롭다운 선택
        let detailJobSelected: Observable<DropdownDisplayable>  // 드롭다운 선택
    }
    
    struct Output {
        let initialNickname: Driver<String>          // 초기 닉네임 (진입 시 1회)
        let isCompleteEnabled: Driver<Bool>          // 완료 버튼 활성화 여부
        let validationResult: Signal<NicknameValidationResult> // 검증 결과 (경고 메시지 표시용)
        let updateSuccess: Signal<Void>              // 최종 수정 성공 이벤트
        
        // Job 관련 Output
        let jobList: Driver<[DropdownDisplayable]>          // 직업 리스트
        let detailJobList: Driver<[DropdownDisplayable]>    // 세부직무 리스트
        let currentJobName: Driver<String?>                 // 버튼 텍스트용
        let currentDetailJobName: Driver<String?>           // 버튼 텍스트용
        let selectedJobId: Driver<Int?>                     // 드롭다운 하이라이트용
        let selectedDetailJobId: Driver<Int?>               // 드롭다운 하이라이트용
        let isDetailJobEnabled: Driver<Bool>
        
        let jobWarning: Driver<String?>                     // 직업 선택 관련 경고 메시지
    }
    
    private let disposeBag = DisposeBag()
    
    // UI 상태 관리
    private let nicknameRelay: BehaviorRelay<String>
    let initialNicknameValue: String
    
    let savedData = TokenStorageService.shared.getCurationData()
    
    // Job 상태관리
    let selectedJobRelay = BehaviorRelay<Job?>(value: TokenStorageService.shared.getCurationData()?.job)
    let selectedDetailJobRelay = BehaviorRelay<JobDetail?>(value: TokenStorageService.shared.getCurationData()?.jobDetail)
    private let jobListRelay = BehaviorRelay<[Job]>(value: [])
    private let detailJobListRelay = BehaviorRelay<[JobDetail]>(value: [])
    
    private let jobWarningRelay = PublishRelay<String?>()
    
    // 외부 의존성
    private let nicknameServiceVM: NicknameSelectViewModel
    private let jobService: JobService
    
    init(currentNickname: String, nicknameServiceVM: NicknameSelectViewModel, jobService: JobService = .shared) {
        self.initialNicknameValue = currentNickname
        self.nicknameRelay = BehaviorRelay<String>(value: currentNickname)
        self.nicknameServiceVM = nicknameServiceVM
        self.jobService = jobService
    }
    
    func transform(input: Input) -> Output {
        let validationResultRelay = PublishRelay<NicknameValidationResult>()
        let updateSuccessRelay = PublishRelay<Void>()
        
        // 1. 초기 닉네임 Driver
        let initialNicknameDriver = Driver.just(initialNicknameValue)
        
        // 2. 텍스트 필드 입력값과 Relay 동기화
        input.nicknameInput
            .distinctUntilChanged()
            .bind(to: nicknameRelay)
            .disposed(by: disposeBag)
        
        // 3. Clear 버튼
        input.clearButtonTapped
            .map { "" }
            .bind(to: nicknameRelay)
            .disposed(by: disposeBag)
        
        // 4. 완료 버튼 활성화 조건
        let isCompleteEnabled = Observable.combineLatest(
            nicknameRelay,
            selectedJobRelay,
            selectedDetailJobRelay
        )
            .map { [weak self] (nickname, job, jobDetail) -> Bool in
                guard let self = self else { return false }
                
                let trimmed = nickname.trimmingCharacters(in: .whitespaces)
                
                let nicknameChanged = trimmed != self.initialNicknameValue
                let jobChanged = job?.id != self.savedData?.job?.id
                let jobDetailChanged = jobDetail?.id != self.savedData?.jobDetail?.id
                
                return nicknameChanged || jobChanged || jobDetailChanged
            }
            .asDriver(onErrorJustReturn: false)
        
        // Job Logic
        // 1. 직업 버튼 탭 -> Service 호출
        input.jobButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<[Job]> in
                guard let self = self else { return .empty() }
                return self.jobService.fetchJobs()
            }
            .bind(to: jobListRelay)
            .disposed(by: disposeBag)
        
        // 2. 직업 선택 시
        input.jobSelected
            .map { $0 as? Job }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] job in
                self?.selectedJobRelay.accept(job)
                
                // 직업이 변경되면 하위 데이터 초기화
                self?.selectedDetailJobRelay.accept(nil)
                self?.detailJobListRelay.accept([])
            })
            .disposed(by: disposeBag)
        
        // 3. 세부 직무 버튼 탭 -> Service 호출 (Job ID 필요)
        input.detailJobButtonTapped
            .withLatestFrom(selectedJobRelay)
            .flatMapLatest { [weak self] job -> Observable<[JobDetail]> in
                guard let self = self, let jobId = job?.id else { return .just([]) }
                return self.jobService.fetchJobDetails(jobId: jobId)
            }
            .bind(to: detailJobListRelay)
            .disposed(by: disposeBag)
        
        // 4. 세부 직무 선택 시
        input.detailJobSelected
            .map { $0 as? JobDetail }
            .compactMap { $0 }
            .do(onNext: { [weak self] _ in
                self?.jobWarningRelay.accept(nil) // 경고 숨김
            })
            .bind(to: selectedDetailJobRelay)
            .disposed(by: disposeBag)
        
        // 완료 버튼 탭 로직
                // 순서: 1. 직무 검사 -> 2. 닉네임 검사 -> 3. API 호출
                input.completeButtonTapped
                    .withLatestFrom(Observable.combineLatest(
                        nicknameRelay,
                        selectedJobRelay,
                        selectedDetailJobRelay
                    ))
                    .flatMapLatest { [weak self] (nickname, job, jobDetail) -> Observable<Bool> in
                        guard let self = self else { return .just(false) }
                        
                        // 1. 직업 유효성 검사
                        if let currentJob = job {
                            let requiredJobs = ["학생", "직장인", "취준생"]
                            // 해당 직업군인데 세부 직무가 없으면?
                            if requiredJobs.contains(currentJob.jobName) && jobDetail == nil {
                                // 경고 메시지 띄우고
                                self.jobWarningRelay.accept("*세부 직무를 선택해주세요.")
                                // 여기서 흐름 종료 (API 호출 안 함)
                                return .just(false)
                            }
                        }
                        
                        // 통과했다면 경고 메시지 지움
                        self.jobWarningRelay.accept(nil)
                        
                        // 2.닉네임 변경 여부 확인 (기존 로직 유지)
                        
                        let nicknameChanged = nickname.trimmingCharacters(in: .whitespaces) != self.initialNicknameValue
                        
                        // 닉네임이 안 바뀌었으면? -> 중복 체크 없이 바로 저장 API 호출
                        // (직업만 바꿨을 수도 있으니까요)
                        if !nicknameChanged {
                            return self.requestUpdateProfile(
                                nickname: nickname,
                                jobId: job?.id,
                                jobDetailId: jobDetail?.id
                            )
                        }
                        
                        // 3. 닉네임 기본 유효성 검사 (기존 로직 유지)
                        let basicValidation = self.validateNickname(nickname)
                        
                        // 검사 실패 시
                        guard case .success = basicValidation else {
                            validationResultRelay.accept(basicValidation) // 에러 메시지 띄우기
                            return .just(false) // 흐름 종료
                        }
                        
                        // 4. [EXISTING] 닉네임 중복 체크 API (기존 로직 유지)
                        return self.nicknameServiceVM.checkNicknameDuplicate(nickname)
                            .flatMap { result -> Observable<Bool> in
                                validationResultRelay.accept(result) // 결과 UI 전달
                                
                                if result == .success {
                                    // 중복 체크 통과 -> 최종 저장 API 호출
                                    return self.requestUpdateProfile(
                                        nickname: nickname,
                                        jobId: job?.id,
                                        jobDetailId: jobDetail?.id
                                    )
                                } else {
                                    // 중복됨 -> 중단
                                    return .just(false)
                                }
                            }
                    }
                    .subscribe(onNext: { [weak self] success in
                        
                        // 5.성공 후 처리
                        if success {
                            if let self = self {
                                var currentData = TokenStorageService.shared.getCurationData() ?? CurationData()
                                currentData.nickname = self.nicknameRelay.value
                                currentData.job = self.selectedJobRelay.value
                                currentData.jobDetail = self.selectedDetailJobRelay.value
                                TokenStorageService.shared.saveCurationData(currentData)
                            }
                            updateSuccessRelay.accept(())
                        }
                    })
                    .disposed(by: disposeBag)
        
        let isDetailJobEnabled = selectedJobRelay
            .map { job -> Bool in
                guard let jobName = job?.jobName else { return false }
                return jobName != "자영업"  // 자영업이 아니면 활성화
            }
            .asDriver(onErrorJustReturn: false)
        
        // 세부 직무 미선택 경고 로직
        // "학생", "직장인", "취준생"을 골랐는데 세부직무가 없으면 경고 메시지 리턴
//        let jobWarning = Observable.combineLatest(selectedJobRelay, selectedDetailJobRelay)
//            .map { job, detail -> String? in
//                guard let currentJob = job else { return nil }
//                
//                let requiredJobs = ["학생", "직장인", "취준생"]
//                if requiredJobs.contains(currentJob.jobName) && detail == nil {
//                    return "*세부 직무를 선택해주세요."
//                }
//                return nil
//            }
//            .asDriver(onErrorJustReturn: nil)
        
        let jobWarning = jobWarningRelay.asDriver(onErrorJustReturn: nil)
        
        return Output(
            initialNickname: initialNicknameDriver,
            isCompleteEnabled: isCompleteEnabled,
            validationResult: validationResultRelay.asSignal(),
            updateSuccess: updateSuccessRelay.asSignal(),
            
            // job output mapping
            jobList: jobListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            detailJobList: detailJobListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            currentJobName: selectedJobRelay.map { $0?.jobName }.asDriver(onErrorJustReturn: nil),
            currentDetailJobName: selectedDetailJobRelay.map { $0?.jobDetailName }.asDriver(onErrorJustReturn: nil),
            selectedJobId: selectedJobRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            selectedDetailJobId: selectedDetailJobRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            isDetailJobEnabled: isDetailJobEnabled,
            
            jobWarning: jobWarning
        )
    }
    
    // MARK: - API Request
    private func requestUpdateProfile(nickname: String, jobId: Int?, jobDetailId: Int?) -> Observable<Bool> {
        return Observable.create { observer in
            // 1. NetworkDefine에서 정의한 URL 사용
            let urlString = NetworkDefine.ProfileAPI.updateProfile.url
            
            // 2. 리프레시 토큰 가져오기
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                print("❌ Refresh Token 없음")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 3. 헤더 설정 (jwt-token에 리프레시 토큰 포함)
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "jwt-token": refreshToken
            ]
            
            // 4. 바디 파라미터 설정 (직업 정보 추가)
            var parameters: [String: Any] = [
                "nickname": nickname
            ]
            
            if let jobId = jobId {
                parameters["jobId"] = jobId
            }
            
            if let jobDetailId = jobDetailId {
                parameters["jobDetailId"] = jobDetailId
            }
            
            print("📡 프로필 수정 요청: \(urlString)")
            print("📦 파라미터: \(parameters)")
            
            // 5. Alamofire 요청 (Method: PUT)
            let request = AF.request(
                urlString,
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("📥 프로필 수정 응답: \(value)")
                        
                        // 성공 여부 파싱 (서버 응답 구조: { "success": true, ... })
                        if let json = value as? [String: Any],
                           let success = json["success"] as? Bool {
                            
                            if success {
                                // TokenStorageService에 저장은 subscribe에서 처리
                                observer.onNext(true)
                            } else {
                                // success가 false인 경우 (메시지 출력 등)
                                let message = json["message"] as? String ?? "알 수 없는 오류"
                                print("❌ 실패 메시지: \(message)")
                                observer.onNext(false)
                            }
                        } else {
                            // JSON 파싱 실패 시에도 일단 false 처리
                            observer.onNext(false)
                        }
                        
                    case .failure(let error):
                        print("❌ 요청 실패: \(error.localizedDescription)")
                        observer.onNext(false)
                    }
                    observer.onCompleted()
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK: - Validation Logic
    private func validateNickname(_ nickname: String) -> NicknameValidationResult {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return .empty }
        if trimmed.count < 2 { return .tooShort }
        if trimmed.count > 10 { return .tooLong }
        if !isOnlyKorean(trimmed) { return .invalidCharacters }
        if !isCompleteKorean(trimmed) { return .incompleteKorean }
        return .success
    }
    
    private func isOnlyKorean(_ text: String) -> Bool {
        let koreanPattern = "^[가-힣ㄱ-ㅎㅏ-ㅣ\\s]*$"
        return NSPredicate(format: "SELF MATCHES %@", koreanPattern).evaluate(with: text)
    }
    
    private func isCompleteKorean(_ text: String) -> Bool {
        let trimmed = text.replacingOccurrences(of: " ", with: "")
        for char in trimmed {
            let scalar = char.unicodeScalars.first!.value
            let isCompleteHangul = (0xAC00...0xD7A3).contains(scalar)
            let isJamo = (0x3131...0x318E).contains(scalar)
            if !isCompleteHangul && isJamo { return false }
        }
        return true
    }
}
