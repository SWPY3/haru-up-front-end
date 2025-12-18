//
//  JobSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa


final class JobSelectViewModel {
    // Input
    struct Input {
        let jobSelected: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    // Output
    struct Output {
        let jobs: Driver<[String]>
        let selectedJob: Driver<String?>
    }
    
    private weak var coordinator: JobSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    // 직업 목록 (실제로는 API나 다른 곳에서 가져올 수 있음)
    private let jobList = BehaviorRelay<[String]>(value: [
        "직장인",
        "자영업",
        "학생",
        "취준생"
    ])
    
    private let currentSelectedJob = BehaviorRelay<String?>(value: nil)
    
    init(coordinator: JobSelectCoordinator) {
        self.coordinator = coordinator
        print("🔴 JobSelectViewModel init - coordinator: \(coordinator)")
    }
    
    func transform(input: Input) -> Output {
        input.jobSelected
            .bind(to: currentSelectedJob)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentSelectedJob)
            .subscribe(onNext: { [weak self] selectedJob in
                print("🔵 다음 버튼 탭됨")
                print("🔵 선택된 직업: \(selectedJob ?? "없음")")
                guard let selectedJob = selectedJob else {
                    print("직업을 선택해주세요.")
                    return
                }
                print("🔵 Coordinator 호출 시작")
                self?.coordinator?.showjobDetailFlow(selectedJob: selectedJob)
            })
            .disposed(by: disposeBag)
        
        return Output(
            jobs: jobList.asDriver(),
            selectedJob: currentSelectedJob.asDriver()
            )
    }
}
