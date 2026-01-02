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
    }
    
    struct Output {
        let isCompleteEnabled: Driver<Bool>
        let updateSuccess: Signal<Void>
        
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
    
    // 외부 의존성
    private let interestService: InterestsService
    
    init(interestService: InterestsService = .shared) {
        self.interestService = interestService
    }
    
    func transform(input: Input) -> Output {
        let updateSuccessRelay = PublishRelay<Void>()
        
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
            })
            .disposed(by: disposeBag)
        
        // 5. 목표 버튼 탭 -> Service 호출 (DetailInterest ID 필요)
        input.goalButtonTapped
            .withLatestFrom(selectedDetailInterestRelay)
            .flatMapLatest { [weak self] detailInterest -> Observable<[Goal]> in
                guard let self = self, let detailId = detailInterest?.id else { return .just([]) }
                return self.interestService.fetchGoals(parentId: detailId)
                    .catch { error in
                        print("❌ 목표 목록 조회 실패: \(error)")
                        return .just([]) // 에러 처리 추가
                    }
            }
            .bind(to: goalListRelay)
            .disposed(by: disposeBag)
        
        // 6. 목표 선택 시
        input.goalSelected
            .map { $0 as? Goal }
            .compactMap { $0 }
            .bind(to: selectedGoalRelay)
            .disposed(by: disposeBag)
        
        // 7. 완료 버튼 활성화 조건
        let isCompleteEnabled = Observable.combineLatest(
            selectedInterestRelay,
            selectedDetailInterestRelay,
            selectedGoalRelay
        )
            .map { [weak self] (interest, detail, goal) -> Bool in
                guard let self = self else { return false }
                
                // 관심사, 세부관심사, 목표가 모두 선택되어 있어야 함
                guard interest != nil, detail != nil, goal != nil else {
                    return false
                }
                
                // 변경 여부 체크
                let interestChanged = interest?.id != self.savedData?.interest?.id
                let detailChanged = detail?.id != self.savedData?.interestDetail?.id
                let goalChanged = goal?.id != self.savedData?.goal?.id
                
                // 하나라도 변경되었으면 활성화
                return interestChanged || detailChanged || goalChanged
            }
            .asDriver(onErrorJustReturn: false)
        
        // 8. 완료 버튼 탭 로직
        input.completeButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                
                return self.requestUpdateInterest(
                    interestId: self.selectedInterestRelay.value?.id,
                    detailInterestId: self.selectedDetailInterestRelay.value?.id,
                    goalId: self.selectedGoalRelay.value?.id
                )
            }
            .subscribe(onNext: { [weak self] success in
                if success {
                    if let self = self {
                        var currentData = TokenStorageService.shared.getCurationData() ?? CurationData()
                        
                        if let interest = self.selectedInterestRelay.value {
                            currentData.interest = InterestData(id: interest.id, name: interest.title)
                        } else {
                            currentData.interest = nil
                        }
                        
                        if let detail = self.selectedDetailInterestRelay.value {
                            currentData.interestDetail = InterestData(id: detail.id, name: detail.name)
                        } else {
                            currentData.interestDetail = nil
                        }
                        
                        if let goal = self.selectedGoalRelay.value {
                            currentData.goal = InterestData(id: goal.id, name: goal.name)
                        } else {
                            currentData.goal = nil
                        }
                        
                        TokenStorageService.shared.saveCurationData(currentData)
                    }
                    updateSuccessRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
//        return Output(
//            isCompleteEnabled: isCompleteEnabled,
//            updateSuccess: updateSuccessRelay.asSignal(),
//            
//            interestList: interestListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
//            detailInterestList: detailInterestListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
//            goalList: goalListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
//            currentInterestName: selectedInterestRelay.map { $0?.name }.asDriver(onErrorJustReturn: nil),
//            currentDetailInterestName: selectedDetailInterestRelay.map { $0?.name }.asDriver(onErrorJustReturn: nil),
//            currentGoalName: selectedGoalRelay.map { $0?.name }.asDriver(onErrorJustReturn: nil),
//            selectedInterestId: selectedInterestRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
//            selectedDetailInterestId: selectedDetailInterestRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
        //            selectedGoalId: selectedGoalRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil)
        //        )
        return Output(
            isCompleteEnabled: isCompleteEnabled,
            updateSuccess: updateSuccessRelay.asSignal(),
            
            interestList: interestListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            detailInterestList: detailInterestListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            goalList: goalListRelay.map { $0 as [DropdownDisplayable] }.asDriver(onErrorJustReturn: []),
            
            currentInterestName: selectedInterestRelay.map { $0?.title }.asDriver(onErrorJustReturn: nil),
            
            currentDetailInterestName: selectedDetailInterestRelay.map { $0?.name }.asDriver(onErrorJustReturn: nil),
            currentGoalName: selectedGoalRelay.map { $0?.name }.asDriver(onErrorJustReturn: nil),
            
            selectedInterestId: selectedInterestRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            selectedDetailInterestId: selectedDetailInterestRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil),
            selectedGoalId: selectedGoalRelay.map { $0?.id }.asDriver(onErrorJustReturn: nil)
        )
    }
    
    // MARK: - API Request
    private func requestUpdateInterest(interestId: Int?, detailInterestId: Int?, goalId: Int?) -> Observable<Bool> {
        return Observable.create { observer in
            var targetMemberInterestId: Int? = UserStorage.shared.selectedMemberInterestId
            
            if targetMemberInterestId == nil {
                // UserStorage에 없다면 CurationData에서 찾아봄 (Fallback)
                if let curationData = TokenStorageService.shared.getCurationData(),
                   let ids = curationData.memberInterestIds,
                   let firstId = ids.first {
                    targetMemberInterestId = firstId
                }
            }
            
            // ID가 여전히 없으면 에러 처리
            guard let memberInterestId = targetMemberInterestId else {
                print("❌ memberInterestId를 찾을 수 없습니다. (UserStorage 및 CurationData 모두 없음)")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 2. 목표 ID가 최종 interestId (필수)
            guard let finalInterestId = goalId else {
                print("❌ 목표(Goal)를 선택해야 합니다")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 3. directFullPath 생성
            var directFullPath: [String] = []
            
            if let interest = self.selectedInterestRelay.value {
                directFullPath.append(interest.title)
            }
            if let detail = self.selectedDetailInterestRelay.value {
                directFullPath.append(detail.name)
            }
            if let goal = self.selectedGoalRelay.value {
                directFullPath.append(goal.name)
            }
            
            guard directFullPath.count == 3 else {
                print("❌ directFullPath가 완전하지 않음 (관심사, 세부관심사, 목표 모두 필요)")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 4. URL 생성 (memberInterestId 포함)
            let urlString = "\(NetworkDefine.InterestsAPI.member.url)/\(memberInterestId)"
            
            guard let accessToken = TokenStorageService.shared.getAccessToken() else {
                print("❌ Access Token 없음")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            let parameters: [String: Any] = [
                "interestId": finalInterestId,
                "directFullPath": directFullPath
            ]
            
            print("📡 관심사 수정 요청: \(urlString)")
            print("📦 파라미터: \(parameters)")
            
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
                        print("📥 관심사 수정 응답: \(value)")
                        observer.onNext(true)
                        
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
}

