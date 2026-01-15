//
//  AgreeViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 1/15/26.
//

import Foundation
import RxSwift
import RxCocoa

final class AgreeViewModel {
    struct Input {
        let allCheckTap: Observable<Void>
        let term1CheckTap: Observable<Void>
        let term2CheckTap: Observable<Void>
        let term3CheckTap: Observable<Void>
        
        let term1DetailTap: Observable<Void>
        let term2DetailTap: Observable<Void>
        
        let confirmButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isAllChecked: Driver<Bool>
        let isTerm1Checked: Driver<Bool>
        let isTerm2Checked: Driver<Bool>
        let isTerm3Checked: Driver<Bool>
        
        let isConfirmButtonEnabled: Driver<Bool>
        
        // Coordinator로 보낼 신호
        let navigateToTerm1Detail: Signal<Void>
        let navigateToTerm2Detail: Signal<Void>
        let didTapConfirm: Signal<Void>
    }
    
    private let disposeBag = DisposeBag()
    
    // 상태 관리용 Relay
    private let term1Relay = BehaviorRelay<Bool>(value: false)
    private let term2Relay = BehaviorRelay<Bool>(value: false)
    private let term3Relay = BehaviorRelay<Bool>(value: false)
    
    func transform(input: Input) -> Output {
        
        // 1. 개별 체크박스 토글 로직
        input.term1CheckTap
            .withLatestFrom(term1Relay)
            .map { !$0 }
            .bind(to: term1Relay)
            .disposed(by: disposeBag)
        
        input.term2CheckTap
            .withLatestFrom(term2Relay)
            .map { !$0 }
            .bind(to: term2Relay)
            .disposed(by: disposeBag)
        
        input.term3CheckTap
            .withLatestFrom(term3Relay)
            .map { !$0 }
            .bind(to: term3Relay)
            .disposed(by: disposeBag)
        
        // 2. 전체 동의 체크박스 로직
        // 전체 동의 버튼을 누르면 -> 현재 상태가 모두 true가 아니면 전부 true로, 모두 true면 전부 false로
        let allStateObservable = Observable.combineLatest(term1Relay, term2Relay, term3Relay) { $0 && $1 && $2 }
        
        input.allCheckTap
            .withLatestFrom(allStateObservable)
            .map { !$0 } // 현재 전체 동의 상태의 반대값
            .subscribe(onNext: { [weak self] newState in
                self?.term1Relay.accept(newState)
                self?.term2Relay.accept(newState)
                self?.term3Relay.accept(newState)
            })
            .disposed(by: disposeBag)
        
        // 3. 버튼 활성화 상태 (필수 항목이 모두 체크되었는지)
        // term1, term2, term3 필수
        let isButtonEnabled = Observable.combineLatest(term1Relay, term2Relay, term3Relay)
            .map { $0 && $1 && $2 }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            isAllChecked: allStateObservable.asDriver(onErrorJustReturn: false),
            isTerm1Checked: term1Relay.asDriver(),
            isTerm2Checked: term2Relay.asDriver(),
            isTerm3Checked: term3Relay.asDriver(),
            isConfirmButtonEnabled: isButtonEnabled,
            navigateToTerm1Detail: input.term1DetailTap.asSignal(onErrorJustReturn: ()),
            navigateToTerm2Detail: input.term2DetailTap.asSignal(onErrorJustReturn: ()),
            didTapConfirm: input.confirmButtonTapped.asSignal(onErrorJustReturn: ())
        )
    }
}
