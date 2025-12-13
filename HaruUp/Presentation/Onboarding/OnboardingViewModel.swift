//
//  OnboardingViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/2/25.
//



import Foundation
import RxSwift
import RxCocoa


final class OnboardingViewModel {
    
    // Input
    let nextButtonTapped = PublishSubject<Void>()
    let skipButtonTapped = PublishSubject<Void>()
    
    
    // Output
    let currentPage = BehaviorRelay<Int>(value: 0)
    let isLastPage: Observable<Bool>
    let buttonTitle: Observable<String>
    let shouldComplete = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    private let totalPages = 2
    
    init() {
        
        
        let pages = totalPages
        
        // 마지막 페이지 여부
        isLastPage = currentPage
            .map{ page in
                return page == pages - 1
            }
            .asObservable()
        // 버튼 타이틀
        buttonTitle = isLastPage
            .map{ $0 ? "준비 완료" : "다음" }
        
        setupBindings()
        
    }
    
    private func setupBindings() {
        // 다음 버튼 탭
        nextButtonTapped
            .withLatestFrom(currentPage)
            .subscribe(onNext: { [weak self] page in
                guard let self = self else { return }
                
                if page < self.totalPages - 1 {
                    // 다음 페이지 이동
                    self.currentPage.accept(page + 1)
                }else {
                    // 마지막 페이지 -> 완료
                    self.shouldComplete.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        // 건너뛰기 버튼 탭
        skipButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.shouldComplete.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
