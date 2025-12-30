//
//  InterestSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

final class InterestSelectViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let interestSelected: Observable<Interest>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let interests: Driver<[Interest]>
        let selectedInterest: Driver<Interest?>
        let isLoading: Driver<Bool>
    }
    
    private weak var coordinator: InterestSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let interestList = BehaviorRelay<[Interest]>(value: [])
    private let currentSelectedInterest = BehaviorRelay<Interest?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    init(coordinator: InterestSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[Interest]> in
                guard let self = self else { return .empty() }
                return self.fetchInterestList()
            }
            .bind(to: interestList)
            .disposed(by: disposeBag)
        
        input.interestSelected
            .bind(to: currentSelectedInterest)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentSelectedInterest)
            .subscribe(onNext: { [weak self] interest in
                guard let interest = interest else {
                    print("관심사를 선택해주세요")
                    return
                }
                print("🔵 다음 버튼 탭됨 - 관심사: \(interest.title), ID: \(interest.id)")
                self?.coordinator?.showInterestDetailSelectFlow(selectedInterest: interest)
            })
            .disposed(by: disposeBag)
        
        return Output(
            interests: interestList.asDriver(),
            selectedInterest: currentSelectedInterest.asDriver(),
            isLoading: isLoading.asDriver()
            
        )
    }
    
    private func fetchInterestList() -> Observable<[Interest]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.isLoading.accept(true)
            
            let urlString = NetworkDefine.InterestAPI.getInterestList.url
            
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                print("❌ refreshToken이 없습니다")
                self.isLoading.accept(false)
                observer.onError(NSError(domain: "AuthError", code: 401))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Content-Type" : "application/json",
                "jwt-token": refreshToken
            ]
            
            print("📡 관심사 목록 요청")
            print("🌐 URL: \(urlString)")
            
            let request = AF.request(urlString, method: .get, headers: headers)
                .validate()
                .responseDecodable(of: InterestResponse.self){ [weak self] response in
                    self?.isLoading.accept(false)
                    
                    switch response.result {
                    case .success(let interestResponse):
                        let interests = interestResponse.interests.map { Interest(from: $0) }
                        print("✅ 관심사 목록 조회 성공: \(interests.count)개")
                        interests.forEach { print("  - \($0.title) (ID: \($0.id))") }
                        observer.onNext(interests)
                        observer.onCompleted()
                        
                    case .failure(let error):
                        print("❌ 관심사 목록 조회 실패: \(error.localizedDescription)")
                        
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
