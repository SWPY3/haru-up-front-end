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
        let validationResult: Signal<ValidationResult> // 검증 결과 (경고 메시지 표시용)
        let updateSuccess: Signal<Void>              // 최종 수정 성공 이벤트
        
        // Job 관련 Output
        let jobList: Driver<[DropdownDisplayable]>          // 직업 리스트
        let detailJobList: Driver<[DropdownDisplayable]>    // 세부직무 리스트
        let currentJobName: Driver<String?>                 // 버튼 텍스트용
        let currentDetailJobName: Driver<String?>           // 버튼 텍스트용
        let selectedJobId: Driver<Int?>                     // 드롭다운 하이라이트용
        let selectedDetailJobId: Driver<Int?>               // 드롭다운 하이라이트용
    }
    
    private let disposeBag = DisposeBag()
    
    // UI 상태 관리
    private let nicknameRelay: BehaviorRelay<String>
    private let initialNicknameValue: String
    
    // Job 상태관리
    private let selectedJobRelay = BehaviorRelay<Job?>(value: nil)
    private let selectedDetailJobRelay = BehaviorRelay<JobDetail?>(value: nil)
    private let jobListRelay = BehaviorRelay<[Job]>(value: [])
    private let detailJobListRelay = BehaviorRelay<[JobDetail]>(value: [])
    
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
        let validationResultRelay = PublishRelay<ValidationResult>()
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
        let isCompleteEnabled = nicknameRelay
            .map { [weak self] text -> Bool in
                guard let self = self else { return false }
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let isChanged = trimmed != self.initialNicknameValue
                let isNotEmpty = !trimmed.isEmpty
                
                return isChanged && isNotEmpty
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
            .bind(to: selectedDetailJobRelay)
            .disposed(by: disposeBag)
        
        // 완료 버튼 탭 로직
        input.completeButtonTapped
            .withLatestFrom(nicknameRelay) // 현재 닉네임 가져오기
            .flatMapLatest { [weak self] nickname -> Observable<ValidationResult> in
                guard let self = self else { return .just(.empty) }
                
                // [Step 1] 기본 유효성 검사 (길이, 한글 등)
                let basicValidation = self.validateNickname(nickname)
                guard case .success = basicValidation else {
                    return .just(basicValidation) // 실패 시 즉시 반환
                }
                
                // [Step 2] 닉네임 중복 체크 API 호출 (기존 VM 활용)
                return self.nicknameServiceVM.checkNicknameDuplicate(nickname)
            }
            .flatMapLatest { [weak self] result -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                
                // 결과 UI에 전달 (경고 메시지 표시 등)
                validationResultRelay.accept(result)
                
                if result == .success {
                    // [Step 3] 중복 체크 통과 시 -> 프로필 수정 API 호출
                    return self.requestUpdateProfile(nickname: self.nicknameRelay.value)
                } else {
                    // 중복이거나 기타 오류면 중단
                    return .just(false)
                }
            }
            .subscribe(onNext: { [weak self] success in
                if success {
                    if let self = self {
                        var currentData = TokenStorageService.shared.getCurationData() ?? CurationData()
                        currentData.nickname = self.nicknameRelay.value
                        TokenStorageService.shared.saveCurationData(currentData)
                    }
                    updateSuccessRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
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
            selectedDetailJobId: selectedDetailJobRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil)
            
        )
    }
    
    // MARK: - API Request
    private func requestUpdateProfile(nickname: String) -> Observable<Bool> {
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
            
            // 4. 바디 파라미터 설정
            let parameters: [String: Any] = [
                "nickname": nickname
            ]
            
            print("📡 프로필 수정 요청: \(urlString)")
            print("📦 파라미터: \(parameters)")
            
            // 5. Alamofire 요청 (Method: PATCH)
            let request = AF.request(
                urlString,
                method: .put, // 명세에 맞게 PATCH 사용
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
                                var currentData = TokenStorageService.shared.getCurationData() ?? CurationData()
                                currentData.nickname = self.nicknameRelay.value
                                TokenStorageService.shared.saveCurationData(currentData)
            
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
    private func validateNickname(_ nickname: String) -> ValidationResult {
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
