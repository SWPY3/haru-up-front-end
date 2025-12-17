//
//  TodayMissionListViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TodayMissionListViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTap: Observable<Void>
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let missions: Observable<[RecommendedMissionDTO]>
        let isLoading: Observable<Bool>
        let errorMessage: Observable<String>
        let missionCompleted: Observable<Void>
    }
    
    private let missionService: MissionServiceProtocol
    private let disposeBag = DisposeBag()
    
    // TODO: test용
    private let userId: Int = 4639152463
    private let interests: [InterestDTO] = [.init(seqNo: 1, mainCategory: "운동", middleCategory: "헬스", subCategory: "근력키우기", difficulty: 1)]
    private let dummyMissions: [RecommendedMissionDTO] = [
        .init(seqNo: 1, content: "스쿼트 20회", relatedInterest: "근력키우기", difficulty: 1),
        .init(seqNo: 2, content: "플랭크 1분", relatedInterest: "근력키우기", difficulty: 2),
        .init(seqNo: 3, content: "달리기 20분", relatedInterest: "유산소", difficulty: 3)
    ]
    
    init(missionService: MissionServiceProtocol) {
        self.missionService = missionService
        // TODO: 이전 화면에서 사용자의 정보(CoreData or Server)를 가져와서 표시
    }
    
    func transform(input: Input) -> Output {
        let loadingSubject = BehaviorSubject<Bool>(value: false)
        let errorSubject = PublishSubject<String>()
        
        // 화면 진입 + 새로고침을 하나의 트리거로 합치기
        let trigger = Observable.merge(input.viewDidLoad, input.refreshTap)
        
        let missions = trigger
            .do(onNext: { _ in loadingSubject.onNext(true) })
            .flatMapLatest { [weak self] _ -> Observable<[RecommendedMissionDTO]> in
                guard let self = self else { return .empty() }
                
                // MARK: TEST
                return Observable.just(dummyMissions)
                
                // MARK: API
//                return self.missionService
//                    .fetchRecommendedMissions(userId: userId, interests: interests)
//                    .asObservable()
//                    .map { $0.missions }
//                    .do(onError: { error in
//                        errorSubject.onNext(error.localizedDescription)
//                    })
//                    .catch { _ in .empty() }
            }
            .do(onNext: { _ in loadingSubject.onNext(false) },
                onError: { _ in loadingSubject.onNext(false) })
            .share(replay: 1)
        
        let missionCompleted = input.completeTap
            .do(onNext: { [weak self] in
                self?.missionService.markTodayMissionSelected()
            })
            .map { _ in () }
        
        return Output(
            missions: missions,
            isLoading: loadingSubject.asObservable(),
            errorMessage: errorSubject.asObservable(),
            missionCompleted: missionCompleted
        )
    }
}
