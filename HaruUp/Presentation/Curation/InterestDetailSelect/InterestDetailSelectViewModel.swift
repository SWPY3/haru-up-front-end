//
//  InterestDetailSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class InterestDetailSelectViewModel {
    
    struct Input {
        let interestDetailSelected: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let interestDetails: Driver<[String]>
        let selectedInterestDetail: Driver<String?>
    }
    
    private weak var coordinator: InterestDetailSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedInterest: String
    
    private let currentSelectedInterestDetail = BehaviorRelay<String?>(value: nil)
    
    init(coordinator: InterestDetailSelectCoordinator?, selectedInterest: String) {
        self.coordinator = coordinator
        self.selectedInterest = selectedInterest
    }
    
    private let interestDetailList: [String] = [
        "영어",
        "일본어",
        "중국어",
        "기타 외국어"
    ]
    
    
    func transform(input: Input) -> Output {
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
                // Coordinator를 통해 다음 화면으로 이동
                self?.coordinator?.showNextFlow(selectedInterestDetail: selectedInterestDetail)
            })
            .disposed(by: disposeBag)
        
        return Output(
            interestDetails: Driver.just(interestDetailList),
            selectedInterestDetail: currentSelectedInterestDetail.asDriver()
        )
    }
    
}
