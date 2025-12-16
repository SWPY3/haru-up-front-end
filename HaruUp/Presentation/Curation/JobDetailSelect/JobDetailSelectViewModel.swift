//
//  JobDetailSelect.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import RxSwift
import RxCocoa


final class JobDetailSelectViewModel {
    struct Input {
        let jobDetailSelected: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let jobDetails: Driver<[String]>
        let selectedJobDetail: Driver<String?>
    }
    
    private weak var coordinator: JobDetailSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedJob: String
    
    private let currentSelectedJobDetail = BehaviorRelay<String?>(value: nil)
    
    // 모든 직업에 일단 동일한 세부 직무 (더미)
    private let jobDetailList: [String] = [
        "디자이너",
        "기획자",
        "개발자",
        "사무직",
        "서비스직",
        "교육 종사자",
        "의료직",
        "예체능",
        "기타"
    ]
    
    init(coordinator: JobDetailSelectCoordinator, selectedJob: String) {
        self.coordinator = coordinator
        self.selectedJob = selectedJob
    }
    
    func transform(input: Input) -> Output {
        // 세부 직무 선택 처리
        input.jobDetailSelected
            .bind(to: currentSelectedJobDetail)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .withLatestFrom(currentSelectedJobDetail)
            .subscribe(onNext: { [weak self] selectedJobDetail in
                guard let selectedJobDetail = selectedJobDetail else {
                    print("세부 직무를 선택해주세요")
                    return
                }
                // Coordinator를 통해 다음 화면으로 이동
                self?.coordinator?.showNextScreen(selectedJobDetail: selectedJobDetail)
            })
            .disposed(by: disposeBag)
        
        return Output(
            jobDetails: Driver.just(jobDetailList),
            selectedJobDetail: currentSelectedJobDetail.asDriver()
        )
    }
    
}
