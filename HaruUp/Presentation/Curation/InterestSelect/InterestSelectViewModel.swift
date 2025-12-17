//
//  InterestSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa


struct Interest {
    let icon: String
    let title: String
}

final class InterestSelectViewModel {
    
    struct Input {
        let interestSelected: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let interests: Driver<[Interest]>
        let selectedInterest: Driver<String?>
    }
    
    private weak var coordinator: InterestSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let interestList = BehaviorRelay<[Interest]>(value: [
        Interest(icon: "🌍", title: "외국어 공부"),
        Interest(icon: "⛹🏻‍♂️", title: "체력관리 및 운동"),
        Interest(icon: "💵", title: "재테크/투자"),
        Interest(icon: "🪪", title: "자격증 공부"),
        Interest(icon: "👩🏻‍💻", title: "직무 관련 역량 개발")
    ])
    
    private let currentSelectedInterest = BehaviorRelay<String?>(value: nil)
    
    init(coordinator: InterestSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
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
                print("🔵 다음 버튼 탭됨 - 관심사: \(interest)")
                self?.coordinator?.showInterestDetailSelectFlow(selectedInterest: interest)
            })
            .disposed(by: disposeBag)
        
        return Output(
            interests: interestList.asDriver(),
            selectedInterest: currentSelectedInterest.asDriver()
        )
    }
}
