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
    }
    
    // Output
    struct Output {
        let jobs: Driver<[String]>
        let selectedJob: Driver<String>
    }
    
    private let disposeBag = DisposeBag()
    
    // 직업 목록 (실제로는 API나 다른 곳에서 가져올 수 있음)
    private let jobList = BehaviorRelay<[String]>(value: [
        "직장인",
        "자영업",
        "학생",
        "취준생"
    ])
    
    func transform(input: Input) -> Output {
        let selectedJob = input.jobSelected
            .asDriver(onErrorJustReturn: "")
        
        return Output(
            jobs: jobList.asDriver(), selectedJob: selectedJob
            )
    }
}
