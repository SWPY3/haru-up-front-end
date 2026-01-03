//
//  JobDetailSelect.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

final class JobDetailSelectViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let jobDetailSelected: Observable<JobDetail>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let jobDetails: Driver<[JobDetail]>
        let selectedJobDetail: Driver<JobDetail?>
        let isLoading: Driver<Bool>
        let titleText: Driver<String>
    }
    
    private weak var coordinator: JobDetailSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedJob: Job
    private let jobService: JobService
    
    private let jobDetailList = BehaviorRelay<[JobDetail]>(value: [])
    private let currentSelectedJobDetail = BehaviorRelay<JobDetail?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    init(coordinator: JobDetailSelectCoordinator, selectedJob: Job, jobService: JobService = .shared) {
        self.coordinator = coordinator
        self.selectedJob = selectedJob
        self.jobService = jobService
    }
    
    func transform(input: Input) -> Output {
        
        input.viewDidLoad
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<[JobDetail]> in
                guard let self = self else { return .empty() }
                return self.jobService.fetchJobDetails(jobId: self.selectedJob.id)
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
            .bind(to: jobDetailList)
            .disposed(by: disposeBag)
        
        // 세부 직무 선택 처리
        input.jobDetailSelected
            .bind(to: currentSelectedJobDetail)
            .disposed(by: disposeBag)
        
        let titleTextString: String
        if self.selectedJob.jobName == "직장인" {
            titleTextString = "세부 직무를 골라주세요."
        } else {
            titleTextString = "하고 싶은 세부 직무를 골라주세요."
        }
        
        let titleTextDriver = Driver.just(titleTextString)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .withLatestFrom(currentSelectedJobDetail)
            .subscribe(onNext: { [weak self] selectedJobDetail in
                print("🔵 다음 버튼 탭됨")
                guard let selectedJobDetail = selectedJobDetail else {
                    print("❌ 세부 직무를 선택해주세요")
                    return
                }
                
                print("🔵 선택된 세부 직무: \(selectedJobDetail.jobDetailName), ID: \(selectedJobDetail.id)")
                self?.coordinator?.showGenderSelectFlow(selectedJobDetail: selectedJobDetail)
            })
            .disposed(by: disposeBag)
        
        return Output(
            jobDetails: jobDetailList.asDriver(),
            selectedJobDetail: currentSelectedJobDetail.asDriver(),
            isLoading: isLoading.asDriver(),
            titleText: titleTextDriver
        )
    }
}
