//
//  LoadingViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class LoadingViewModel {
    private let curationService = CurationService()
    private let disposeBag = DisposeBag()
    
    // Input
    struct Input {
        let viewDidAppear: Observable<Void>
    }
    
    // Output
    struct Output {
        let showBox: Observable<Int>
        let loadingCompleted: Observable<[Int]>
        let error: Observable<Error>
    }
    
    func transform(input: Input, curationData: CurationData) -> Output {
        let showBoxRelay = PublishRelay<Int>()
        let loadingCompletedRelay = PublishRelay<[Int]>()
        let errorRelay = PublishRelay<Error>()
        
        var receivedSteps: Set<String> = []
        var emittedBoxIndexes: Set<Int> = []
        
        func emitBoxOnce(_ index: Int) {
            guard !emittedBoxIndexes.contains(index) else { return }
            emittedBoxIndexes.insert(index)
            showBoxRelay.accept(index)
        }
        
        input.viewDidAppear
            .flatMapLatest { [weak self] _ -> Observable<CurationStreamEvent> in
                guard let self = self else {
                    return Observable.empty()
                }
                return self.curationService.streamCurationLogs(curationData: curationData)
            }
            .subscribe(with: self, onNext: { owner, event in
                switch event {
                case .log(let log):
                    receivedSteps.insert(log.step)
                    if let step = LoadingStep(rawValue: log.step) {
                        print("✅ 매칭된 단계: \(step.rawValue) -> 박스 인덱스 \(step.boxIndex)")
                        
                        switch step {
                        case .characterCreated:
                            print("👤 캐릭터 생성 완료 -> 박스 0")
                            showBoxRelay.accept(0)
                            
                        case .profileSaved:
                            print("📝 프로필 저장 완료 -> 박스 1")
                            showBoxRelay.accept(1)
                            
                        case .jobSet, .jobDetailSet:
                            // 두 단계 모두 받았을 때만 3번째 박스 표시
                            if receivedSteps.contains(LoadingStep.jobSet.rawValue),
                               receivedSteps.contains(LoadingStep.jobDetailSet.rawValue) {
                                showBoxRelay.accept(2)
                            }
                            
                        case .interestSet:
                            showBoxRelay.accept(3)
                            
                        case .goalSet:
                            showBoxRelay.accept(4)
                        }
                    }
                    
                    // ViewModel 내부
                case .completed(let memberInterestIds):
                    // 예외 처리: 데이터가 제대로 왔는지 확인 후 전달
                    if memberInterestIds.isEmpty {
                        print("관심사 ID가 없습니다.")
                    }
                    loadingCompletedRelay.accept(memberInterestIds)
                }
            },
                       onError: { owner, error in
                print("❌ 에러 발생: \(error)")
                errorRelay.accept(error)
            }
            )
            .disposed(by: disposeBag)
        
        return Output(
            showBox: showBoxRelay.asObservable(),
            loadingCompleted: loadingCompletedRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
}

