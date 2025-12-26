//
//  GoalSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire


final class GoalSelectViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let goalSelected: Observable<InterestData>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let goals: Driver<[InterestData]>
        let selectedGoal: Driver<InterestData?>
        let isLoading: Driver<Bool>
    }
    
    private weak var coordinator: GoalSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedInterestDetail: InterestData
    
    
    private let goalList = BehaviorRelay<[InterestData]>(value: [])
    private let currentSelectedGoal = BehaviorRelay<InterestData?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    init(coordinator: GoalSelectCoordinator?, selectedInterestDetail: InterestData) {
        self.coordinator = coordinator
        self.selectedInterestDetail = selectedInterestDetail
    }
    
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[InterestData]> in
                guard let self = self else { return .empty() }
                return self.fetchGoalList(parentId: self.selectedInterestDetail.id)
            }
            .bind(to: goalList)
            .disposed(by: disposeBag)
        
        input.goalSelected
            .bind(to: currentSelectedGoal)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .withLatestFrom(currentSelectedGoal)
            .subscribe(onNext: { [weak self] selectedGoal in
                guard let selectedGoal = selectedGoal else {
                    print("목표를 선택해주세요")
                    return
                }
                
                if selectedGoal.name == "직접 입력하기" {
                    self?.coordinator?.showGoalInputFlow(selectedGoal: selectedGoal)
                } else {
                    self?.coordinator?.showNextFlow(selectedGoal: selectedGoal)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            goals: goalList.asDriver(),
            selectedGoal: currentSelectedGoal.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
    
    // MARK: - API
    private func fetchGoalList(parentId: Int) -> Observable<[InterestData]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.isLoading.accept(true)
            
            let urlString = NetworkDefine.InterestAPI.getGoalList(parentId: parentId).url
            
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                print("❌ refreshToken이 없습니다")
                self.isLoading.accept(false)
                observer.onError(NSError(domain: "AuthError", code: 401))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "jwt-token": refreshToken
            ]
            
            // ✅ 파라미터 추가
            let parameters: [String: Int] = ["parentId": parentId]
            
            print("📡 목표 목록 요청")
            print("🌐 URL: \(urlString)")
            print("🔑 parentId: \(parentId)")
            
            let request = AF.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            )
                .validate()
                .responseDecodable(of: InterestResponse.self) { [weak self] response in
                    self?.isLoading.accept(false)
                    
                    switch response.result {
                    case .success(let interestResponse):
                        let goals = interestResponse.interests
                        print("✅ 목표 목록 조회 성공: \(goals.count)개")
                        goals.forEach { print("  - \($0.name) (ID: \($0.id))") }
                        observer.onNext(goals)
                        observer.onCompleted()
                        
                    case .failure(let error):
                        print("❌ 목표 목록 조회 실패: \(error.localizedDescription)")
                        
                        if let statusCode = response.response?.statusCode {
                            print("📛 HTTP Status Code: \(statusCode)")
                        }
                        
                        observer.onNext([])
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
}
