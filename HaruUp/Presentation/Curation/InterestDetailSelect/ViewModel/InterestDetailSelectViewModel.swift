//
//  InterestDetailSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

final class InterestDetailSelectViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let interestDetailSelected: Observable<InterestDetail>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let interestDetails: Driver<[InterestDetail]>
        let selectedInterestDetail: Driver<InterestDetail?>
        let isLoading: Driver<Bool>
    }
    
    private weak var coordinator: InterestDetailSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedInterest: Interest
    
    
    private let interestDetailList = BehaviorRelay<[InterestDetail]>(value: [])
    private let currentSelectedInterestDetail = BehaviorRelay<InterestDetail?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    init(coordinator: InterestDetailSelectCoordinator?, selectedInterest: Interest) {
        self.coordinator = coordinator
        self.selectedInterest = selectedInterest
    }
    
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[InterestDetail]> in
                guard let self = self else { return .empty() }
                return self.fetchInterestDetailList(parentId: self.selectedInterest.id)
            }
            .bind(to: interestDetailList)
            .disposed(by: disposeBag)
        
        input.interestDetailSelected
            .bind(to: currentSelectedInterestDetail)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .withLatestFrom(currentSelectedInterestDetail)
            .subscribe(onNext: { [weak self] selectedInterestDetail in
                guard let selectedInterestDetail = selectedInterestDetail else {
                    print("세부 직무를 선택해주세요")
                    return
                }
                
                print("🔵 선택된 세부 관심사: \(selectedInterestDetail.name), ID: \(selectedInterestDetail.id)")
                
                if selectedInterestDetail.name == "기타" {
                    self?.coordinator?.showForeignLanguageInput(id: selectedInterestDetail.id)
                } else {
                    self?.coordinator?.showGoalSelectFlow(selectedInterestDetail: selectedInterestDetail)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            interestDetails: interestDetailList.asDriver(),
            selectedInterestDetail: currentSelectedInterestDetail.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
    
    // MARK: - API
    private func fetchInterestDetailList(parentId: Int) -> Observable<[InterestDetail]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.isLoading.accept(true)
            
            let urlString = NetworkDefine.InterestAPI.getInterestDetail(parentId: parentId).url
            
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
            
            print("📡 세부 관심사 목록 요청")
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
                    debugPrint(response)
                    self?.isLoading.accept(false)
                    
                    switch response.result {
                    case .success(let interestResponse):
                        let interestDetails = interestResponse.interests.map { InterestDetail(from: $0) }
                        print("✅ 세부 관심사 목록 조회 성공: \(interestDetails.count)개")
                        interestDetails.forEach { print("  - \($0.name) (ID: \($0.id))") }
                        observer.onNext(interestDetails)
                        observer.onCompleted()
                        
                    case .failure(let error):
                        print("❌ 세부 관심사 목록 조회 실패: \(error.localizedDescription)")
                        
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
