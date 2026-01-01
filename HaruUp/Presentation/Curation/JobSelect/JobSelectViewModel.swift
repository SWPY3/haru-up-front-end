//
//  JobSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire


final class JobSelectViewModel {
    // Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let jobSelected: Observable<Job>
        let nextButtonTapped: Observable<Void>
    }
    
    // Output
    struct Output {
        let jobs: Driver<[Job]>
        let selectedJob: Driver<Job?>
        let isLoading: Driver<Bool>
    }
    
    private weak var coordinator: JobSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let jobService: JobService
    
    // 직업 목록
    private let jobList = BehaviorRelay<[Job]>(value: [])
    private let currentSelectedJob = BehaviorRelay<Job?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    
    init(coordinator: JobSelectCoordinator, jobService: JobService = .shared) {
        self.coordinator = coordinator
        self.jobService = jobService
        print("🔴 JobSelectViewModel init - coordinator: \(coordinator)")
    }
    
    func transform(input: Input) -> Output {
        
        // 화면 로드 시 직업 목롤 호출
        input.viewDidLoad
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) }) // 로딩 시작
            .flatMapLatest { [weak self] _ -> Observable<[Job]> in
                guard let self = self else { return .empty() }
                return self.jobService.fetchJobs()
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) }) // 로딩 끝
            .bind(to: jobList)
            .disposed(by: disposeBag)
        // 직업 선택
        input.jobSelected
            .bind(to: currentSelectedJob)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentSelectedJob)
            .subscribe(onNext: { [weak self] selectedJob in
                print("🔵 다음 버튼 탭됨")
                guard let selectedJob = selectedJob else {
                    print("직업을 선택해주세요.")
                    return
                }
                
                print("🔵 선택된 직업: \(selectedJob.jobName), id: \(selectedJob.id)")
                print("🔵 Coordinator 호출 시작")
                self?.coordinator?.showjobDetailFlow(selectedJob: selectedJob)
            })
            .disposed(by: disposeBag)
        
        return Output(
            jobs: jobList.asDriver(),
            selectedJob: currentSelectedJob.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
}
