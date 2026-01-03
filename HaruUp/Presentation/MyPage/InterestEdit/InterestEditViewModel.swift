//
//  InterestEditViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 1/2/26.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class InterestEditViewModel {
    
    struct Input {
        let interestButtonTapped: Observable<Void>
        let detailInterestButtonTapped: Observable<Void>
        let goalButtonTapped: Observable<Void>
        let interestSelected: Observable<DropdownDisplayable>
        let detailInterestSelected: Observable<DropdownDisplayable>
        let goalSelected: Observable<DropdownDisplayable>
        let completeButtonTapped: Observable<Void>
        let foreignLanguageInput: Observable<String>
        let goalInputText: Observable<String>
    }
    
    struct Output {
        let isCompleteEnabled: Driver<Bool>
        let updateSuccess: Signal<Void>
        let errorMessage: Signal<String>
        let isLoading: Driver<Bool>
        
        // Interest 관련 Output
        let interestList: Driver<[DropdownDisplayable]>
        let detailInterestList: Driver<[DropdownDisplayable]>
        let goalList: Driver<[DropdownDisplayable]>
        let currentInterestName: Driver<String?>
        let currentDetailInterestName: Driver<String?>
        let currentGoalName: Driver<String?>
        let selectedInterestId: Driver<Int?>
        let selectedDetailInterestId: Driver<Int?>
        let selectedGoalId: Driver<Int?>
        let showLanguageInputBottomSheet: Signal<Void>
        
        // Goal 관련 Output
        let showGoalInputBottomSheet: Signal<Void>      // 목표 입력 바텀시트 열기
        let goalValidationSuccess: Signal<Void>         // 유효성 검사 성공 (바텀시트 닫기용)
        let goalValidationFailed: Signal<String>        // 유효성 검사 실패 (에러 메시지 표시용)
        let showLockAlert: Signal<Void>                 // 3회 실패 팝업
        let goalLockTimerMessage: Driver<String?>       // 메인 화면 타이머 메시지
        let isGoalButtonEnabled: Driver<Bool>
    }
    
    private let disposeBag = DisposeBag()
    
    let savedData = TokenStorageService.shared.getCurationData()
    
    // Interest 상태관리
    let selectedInterestRelay = BehaviorRelay<Interest?>(
        value: TokenStorageService.shared.getCurationData()?.interest.map { Interest(from: $0) }
    )
    let selectedDetailInterestRelay = BehaviorRelay<InterestDetail?>(
        value: TokenStorageService.shared.getCurationData()?.interestDetail.map { InterestDetail(from: $0) }
    )
    let selectedGoalRelay = BehaviorRelay<Goal?>(
        value: TokenStorageService.shared.getCurationData()?.goal.map { Goal(from: $0) }
    )
    
    private let interestListRelay = BehaviorRelay<[Interest]>(value: [])
    private let detailInterestListRelay = BehaviorRelay<[InterestDetail]>(value: [])
    private let goalListRelay = BehaviorRelay<[Goal]>(value: [])
    
    private let customDetailInterestNameRelay = BehaviorRelay<String?>(value: nil)
    private let customGoalNameRelay = BehaviorRelay<String?>(value: nil)
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    // 타이머 및 락 상태
    private var invalidGoalAttemptCount = 0
    private var goalLockoutRemainingSeconds = 0
    private var goalLockoutTimer: Timer?
    private let goalLockWarningRelay = BehaviorRelay<String?>(value: nil)
    
    
    // 외부 의존성
    private let interestService: InterestsService
    
    init(interestService: InterestsService = .shared) {
        self.interestService = interestService
        
        if let data = TokenStorageService.shared.getCurationData() {
            if let i = data.interest {
                selectedInterestRelay.accept(Interest(from: i))
            }
            if let d = data.interestDetail {
                selectedDetailInterestRelay.accept(InterestDetail(from: d))
                // 저장된 이름이 기본 이름과 다르면 커스텀(외국어 등)일 수 있으므로 처리 가능하나,
                // 여기서는 기본 객체 매핑만 수행합니다.
            }
            if let g = data.goal {
                selectedGoalRelay.accept(Goal(from: g))
            }
        }
    }
    
    func transform(input: Input) -> Output {
        let updateSuccessRelay = PublishRelay<Void>()
        let showBottomSheetRelay = PublishRelay<Void>()
        let errorMessageRelay = PublishRelay<String>()
        
        let showGoalBottomSheetRelay = PublishRelay<Void>()
        let validationSuccessRelay = PublishRelay<Void>()
        let validationFailedRelay = PublishRelay<String>()
        let showLockAlertRelay = PublishRelay<Void>()
        
        // 1. 관심사 버튼 탭 -> Service 호출
        input.interestButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<[Interest]> in
                guard let self = self else { return .empty() }
                return self.interestService.fetchInterest()
                    .catch { error in
                        print("❌ 관심사 목록 조회 실패: \(error)")
                        // 에러 발생 시 빈 배열 반환하여 스트림 끊김(Crash) 방지
                        return .just([])
                    }
            }
            .bind(to: interestListRelay)
            .disposed(by: disposeBag)
        
        // 2. 관심사 선택 시
        input.interestSelected
            .map { $0 as? Interest }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] interest in
                self?.selectedInterestRelay.accept(interest)
                
                // 관심사가 변경되면 하위 데이터 초기화
                self?.selectedDetailInterestRelay.accept(nil)
                self?.selectedGoalRelay.accept(nil)
                self?.detailInterestListRelay.accept([])
                self?.goalListRelay.accept([])
            })
            .disposed(by: disposeBag)
        
        // 3. 세부 관심사 버튼 탭 -> Service 호출 (Interest ID 필요)
        input.detailInterestButtonTapped
            .withLatestFrom(selectedInterestRelay)
            .flatMapLatest { [weak self] interest -> Observable<[InterestDetail]> in
                guard let self = self, let interestId = interest?.id else { return .just([]) }
                return self.interestService.fetchInterestDetails(parentId: interestId)
                    .catch { error in
                        print("❌ 세부 관심사 목록 조회 실패: \(error)")
                        return .just([]) // 에러 처리 추가
                    }
            }
            .bind(to: detailInterestListRelay)
            .disposed(by: disposeBag)
        
        // 4. 세부 관심사 선택 시
        input.detailInterestSelected
            .map { $0 as? InterestDetail }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] detail in
                self?.selectedDetailInterestRelay.accept(detail)
                
                // 세부 관심사가 변경되면 목표 초기화
                self?.selectedGoalRelay.accept(nil)
                self?.goalListRelay.accept([])
                self?.customDetailInterestNameRelay.accept(nil)
                
                if detail.name.contains("기타") {
                    showBottomSheetRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.foreignLanguageInput
            .subscribe(onNext: { [weak self] text in
                self?.customDetailInterestNameRelay.accept(text)
            })
            .disposed(by: disposeBag)
        
        selectedDetailInterestRelay
            .distinctUntilChanged { $0?.id == $1?.id } // 동일한 ID 선택 시 중복 호출 방지
            .flatMapLatest { [weak self] detailInterest -> Observable<[Goal]> in
                guard let self = self, let detailId = detailInterest?.id else {
                    return .just([]) // 세부 관심사가 없으면 빈 배열
                }
                
                // API 호출
                return self.interestService.fetchGoals(parentId: detailId)
                    .catch { error in
                        print("❌ 목표 목록 조회 실패: \(error)")
                        return .just([])
                    }
            }
            .bind(to: goalListRelay) // 결과를 리스트에 바인딩
            .disposed(by: disposeBag)
        
        // 6. 목표 선택 시
        input.goalSelected
            .map { $0 as? Goal }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] goal in
                guard let self = self else { return }
                
                self.selectedGoalRelay.accept(goal)
                
                // "직접" 또는 "직접 입력" 포함 시 처리
                if goal.name.contains("직접") {
                    // 🔒 락 걸려있는지 확인
                    if self.goalLockoutRemainingSeconds > 0 {
                        self.selectedGoalRelay.accept(nil) // 선택 취소
                        return
                    }
                    // 바텀시트 열기 전 기존 커스텀 값 초기화 (재입력 유도)
                    self.customGoalNameRelay.accept(nil)
                    showGoalBottomSheetRelay.accept(())
                } else {
                    // 일반 항목 선택 시 커스텀 값 제거
                    self.customGoalNameRelay.accept(nil)
                }
            })
            .disposed(by: disposeBag)
        
        // 목표 유효성 검사 흐름 (Input -> API -> Success/Fail -> Lock/Timer)
        input.goalInputText
        // 1. 0.5초 동안 중복 입력 방지 (연타 방지)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] text -> Observable<(String, Bool)> in
                
                // TODO: - API 수정되면 다시 연관성 검사 실행하기
                
                // 🚧 [임시 수정] API 오류로 인해 무조건 통과(true) 처리
                // 나중에 API가 고쳐지면 이 부분을 지우고 아래 주석을 푸세요.
                return .just((text, true))
                //                guard let self = self else { return .empty() }
                
                //                return self.interestService.validateGoalInput(text: text)
                //                    .asObservable()
                //                    .map { (text, $0) }
                //                    .catch { error in
                //                        // 2. 취소된 에러(explicitlyCancelled)는 실패로 간주하지 않고 무시함
                //                        if let afError = error.asAFError, afError.isExplicitlyCancelledError {
                //                            print("📡 이전 요청이 취소되었습니다. (무시함)")
                //                            return .empty()
                //                        }
                //
                //                        // 진짜 네트워크 에러나 API 오류만 실패로 처리
                //                        print("❌ Validation Error: \(error)")
                //                        return .just((text, false))
                //                    }
            }
            .subscribe(onNext: { [weak self] (text, isValid) in
                // ... (이후 로직은 기존과 동일) ...
                guard let self = self else { return }
                
                if isValid {
                    // ✅ 성공
                    self.invalidGoalAttemptCount = 0
                    self.customGoalNameRelay.accept(text)
                    validationSuccessRelay.accept(())
                } else {
                    // ❌ 실패 (진짜 실패인 경우만 여기로 옴)
                    self.invalidGoalAttemptCount += 1
                    
                    if self.invalidGoalAttemptCount >= 3 {
                        self.startLockTimer()
                        showLockAlertRelay.accept(())
                        validationSuccessRelay.accept(())
                        self.selectedGoalRelay.accept(nil)
                    } else {
                        validationFailedRelay.accept("*세부 관심사와 맞지 않는 목표예요.")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 7. [수정] 완료 버튼 활성화 로직
        let isCompleteEnabled = Observable.combineLatest(
            selectedInterestRelay,
            selectedDetailInterestRelay,
            selectedGoalRelay,
            goalListRelay,
            customGoalNameRelay
        )
            .map { [weak self] (interest, detail, goal, goalList, customGoalName) -> Bool in
                guard let self = self else { return false }
                
                // 1. 관심사와 세부 관심사는 필수
                guard interest != nil, detail != nil else { return false }
                
                // 2. 목표 선택 여부 판단
                // (리스트가 있는데 목표가 nil이면 안됨)
                let isGoalSelected = goalList.isEmpty || goal != nil
                guard isGoalSelected else { return false }
                
                // 3. 직접 입력일 경우 텍스트 필수 체크
                if let goal = goal, goal.name.contains("직접") {
                    // 직접 입력인데 내용이 없으면 버튼 비활성화
                    if let text = customGoalName, text.trimmingCharacters(in: .whitespaces).isEmpty {
                        return false
                    }
                }
                
                // 4. 변경 사항 체크 (저장된 데이터와 비교)
                let saved = self.savedData
                
                let interestChanged = interest?.id != saved?.interest?.id
                let detailChanged = detail?.id != saved?.interestDetail?.id
                
                // 목표 변경 체크
                let goalChanged: Bool
                if goalList.isEmpty {
                    // 목표 없는 카테고리: 이전에 목표가 있었으면 변경된 것
                    goalChanged = saved?.goal != nil
                } else {
                    // 목표 있는 카테고리
                    // 1) ID가 다른가?
                    let isIdDifferent = goal?.id != saved?.goal?.id
                    
                    // 2) 직접 입력 텍스트가 다른가?
                    let isTextDifferent: Bool
                    if let goal = goal, goal.name.contains("직접") {
                        let currentText = customGoalName ?? ""
                        let savedText = saved?.goal?.name ?? ""
                        isTextDifferent = currentText != savedText
                    } else {
                        isTextDifferent = false
                    }
                    
                    goalChanged = isIdDifferent || isTextDifferent
                }
                
                // 하나라도 변경되었으면 활성화
                return interestChanged || detailChanged || goalChanged
            }
            .asDriver(onErrorJustReturn: false)
        
        
        // 8. 완료 버튼 탭 (최종 수정 API 호출)
        input.completeButtonTapped
            .do(onNext: { [weak self] in
                self?.isLoadingRelay.accept(true) // 로딩 시작
            })
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                return self.requestUpdateInterest(
                    interestId: self.selectedInterestRelay.value?.id,
                    detailInterestId: self.selectedDetailInterestRelay.value?.id,
                    goalId: self.selectedGoalRelay.value?.id
                )
            }
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false) // 로딩 종료
                
                if success {
                    // ✅ API가 성공(true)했을 때만 로컬 데이터 업데이트
                    print("💾 API 성공: 로컬 데이터 업데이트 실행")
                    self.updateLocalData()
                    updateSuccessRelay.accept(())
                } else {
                    // ❌ API 실패(false) 시 에러 메시지
                    print("💾 API 실패: 로컬 데이터 업데이트 안함")
                    errorMessageRelay.accept("관심사 수정에 실패했어요. 다시 시도해주세요.")
                }
            })
            .disposed(by: disposeBag)
        
        let currentDetailName = Driver.combineLatest(selectedDetailInterestRelay.asDriver(), customDetailInterestNameRelay.asDriver()) { $1?.isEmpty == false ? $1 : $0?.name }
        let currentGoalName = Driver.combineLatest(
            selectedGoalRelay.asDriver(),
            customGoalNameRelay.asDriver(),
            goalListRelay.asDriver(),
            selectedDetailInterestRelay.asDriver()
        ) { goal, custom, list, detail -> String? in
            
            // 1순위: 세부 관심사가 없으면 -> 무조건 기본값("목표 선택")
            // (이 코드가 list.isEmpty 체크보다 위에 있어야 합니다!)
            guard detail != nil else { return nil }
            
            // 2순위: 커스텀 입력값이 있으면 -> 커스텀 값
            if let c = custom, !c.isEmpty { return c }
            
            // 3순위: 선택된 목표가 있으면 -> 목표 이름 (로딩 중이어도 표시)
            if let g = goal { return g.name }
            
            // 4순위: 목표도 없고, 리스트도 비어있으면 -> "선택할 목표 없음"
            if list.isEmpty {
                return "선택할 목표 없음"
            }
            
            // 5순위: 리스트는 있는데 선택 안 함 -> 기본값
            return nil
        }
        
        // [수정 2] 목표 버튼 활성화 여부 (저장된 목표가 있으면 활성화 유지)
        let isGoalButtonEnabled = Observable.combineLatest(
            selectedDetailInterestRelay,
            goalListRelay,
            selectedGoalRelay // 목표 상태도 함께 확인
        )
            .map { detail, list, goal -> Bool in
                // 1. 세부 관심사 미선택(초기화) 상태 -> 활성화(흰색)로 보여줌
                if detail == nil { return true }
                
                // 2. 이미 선택된 목표가 있음 -> 리스트 로딩 중이어도 활성화(흰색) 유지
                if goal != nil { return true }
                
                // 3. 그 외 -> 리스트가 있어야 활성화
                return !list.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            isCompleteEnabled: isCompleteEnabled,
            updateSuccess: updateSuccessRelay.asSignal(),
            errorMessage: errorMessageRelay.asSignal(),
            isLoading: isLoadingRelay.asDriver(),
            
            interestList: interestListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            detailInterestList: detailInterestListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            goalList: goalListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            
            currentInterestName: selectedInterestRelay.map { $0?.title }.asDriver(onErrorJustReturn: nil),
            currentDetailInterestName: currentDetailName,
            currentGoalName: currentGoalName,
            
            selectedInterestId: selectedInterestRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            selectedDetailInterestId: selectedDetailInterestRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            selectedGoalId: selectedGoalRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            
            showLanguageInputBottomSheet: showBottomSheetRelay.asSignal(),
            
            showGoalInputBottomSheet: showGoalBottomSheetRelay.asSignal(),
            goalValidationSuccess: validationSuccessRelay.asSignal(),
            goalValidationFailed: validationFailedRelay.asSignal(),
            showLockAlert: showLockAlertRelay.asSignal(),
            goalLockTimerMessage: goalLockWarningRelay.asDriver(),
            isGoalButtonEnabled: isGoalButtonEnabled
        )
    }
    
    private func updateLocalData() {
        var currentData = TokenStorageService.shared.getCurationData() ?? CurationData()
        
        if let interest = self.selectedInterestRelay.value {
            currentData.interest = InterestData(id: interest.id, name: interest.title)
        }
        if let detail = self.selectedDetailInterestRelay.value {
            // 커스텀 이름이 있으면 그걸로 저장
            let name = self.customDetailInterestNameRelay.value ?? detail.name
            currentData.interestDetail = InterestData(id: detail.id, name: name)
        }
        if let goal = self.selectedGoalRelay.value {
            // 커스텀 이름이 있으면 그걸로 저장
            let name = self.customGoalNameRelay.value ?? goal.name
            currentData.goal = InterestData(id: goal.id, name: name)
        }
        
        TokenStorageService.shared.saveCurationData(currentData)
    }
    
    // MARK: - Timer Logic
    private func startLockTimer() {
        goalLockoutRemainingSeconds = 30 * 60 // 30분
        updateTimerMessage()
        
        goalLockoutTimer?.invalidate()
        goalLockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            self.goalLockoutRemainingSeconds -= 1
            
            if self.goalLockoutRemainingSeconds <= 0 {
                t.invalidate()
                self.invalidGoalAttemptCount = 0
                self.goalLockWarningRelay.accept(nil) // 메시지 제거 (락 해제)
            } else {
                self.updateTimerMessage()
            }
        }
    }
    
    private func updateTimerMessage() {
        let min = goalLockoutRemainingSeconds / 60
        let sec = goalLockoutRemainingSeconds % 60
        // 메시지 포맷
        let msg = "*직접입력 목표는 \(min)분 \(sec)초 후에 입력가능해요"
        goalLockWarningRelay.accept(msg)
    }
    
    // MARK: - API Request
    private func requestUpdateInterest(interestId: Int?, detailInterestId: Int?, goalId: Int?) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            // 1. MemberInterestId 가져오기
            var targetMemberInterestId: Int? = UserStorage.shared.selectedMemberInterestId
            if targetMemberInterestId == nil {
                if let data = TokenStorageService.shared.getCurationData(),
                   let ids = data.memberInterestIds,
                   let first = ids.first {
                    targetMemberInterestId = first
                }
            }
            
            guard let memberInterestId = targetMemberInterestId else {
                print("❌ MemberInterestId 없음")
                observer.onNext(false); observer.onCompleted()
                return Disposables.create()
            }
            
            // 2. DirectFullPath 생성
            var directFullPath: [String] = []
            var finalIdToSend: Int?
            
            // (1) 관심사
            if let i = self.selectedInterestRelay.value {
                directFullPath.append(i.title)
            }
            
            // (2) 세부 관심사
            if let d = self.selectedDetailInterestRelay.value {
                // 커스텀 세부관심사 체크
                if let customD = self.customDetailInterestNameRelay.value, !customD.isEmpty {
                    directFullPath.append(customD)
                } else {
                    directFullPath.append(d.name)
                }
            }
            
            // (3) 목표 처리
            if self.goalListRelay.value.isEmpty {
                // ✅ [수정] 목표가 없는 카테고리
                print("ℹ️ 목표가 없는 카테고리입니다. (빈 문자열 전송)")
                finalIdToSend = detailInterestId // 세부 관심사 ID를 최종 ID로 사용
                
                // 빈 문자열을 추가하여 배열 길이를 3으로 맞춤
                directFullPath.append("")
                
            } else {
                // ✅ 목표가 있는 카테고리
                if let g = self.selectedGoalRelay.value {
                    finalIdToSend = g.id
                    
                    if let customG = self.customGoalNameRelay.value, !customG.isEmpty {
                        directFullPath.append(customG)
                    } else {
                        directFullPath.append(g.name)
                    }
                }
            }
            
            // 유효성 검사: 이제 무조건 3개가 됩니다.
            guard let finalId = finalIdToSend, directFullPath.count == 3 else {
                print("❌ 데이터 구성 실패: ID=\(String(describing: finalIdToSend)), Path=\(directFullPath)")
                observer.onNext(false); observer.onCompleted()
                return Disposables.create()
            }
            
            // 3. Service 호출
            print("📡 수정 요청 전송 - ID: \(finalId), Path: \(directFullPath)")
            
            let disposable = self.interestService.updateMemberInterest(
                memberInterestId: memberInterestId,
                interestId: finalId,
                directFullPath: directFullPath
            )
                .subscribe(
                    onSuccess: { _ in
                        print("✅ 수정 성공")
                        observer.onNext(true)
                        observer.onCompleted()
                    },
                    onFailure: { error in
                        print("❌ 수정 실패: \(error.localizedDescription)")
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                )
            
            return Disposables.create { disposable.dispose() }
        }
    }
}
