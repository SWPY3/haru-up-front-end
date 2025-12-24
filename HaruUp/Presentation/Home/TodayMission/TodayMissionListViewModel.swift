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
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    // TODO: test용
    private let userId: Int = 4639152463
    private let interests: [InterestDTO] = [.init(seqNo: 1, mainCategory: "운동", middleCategory: "헬스", subCategory: "근력키우기", difficulty: 1)]
    private let dummyMissions: [RecommendedMissionDTO] = [
        .init(seqNo: 1, content: "스쿼트 20회", relatedInterest: "근력키우기", difficulty: 1),
        .init(seqNo: 2, content: "플랭크 1분", relatedInterest: "근력키우기", difficulty: 2),
        .init(seqNo: 3, content: "달리기 20분", relatedInterest: "유산소", difficulty: 3),
        .init(seqNo: 4, content: "크로스핏 1시간 20분", relatedInterest: "유산소", difficulty: 4),
        .init(seqNo: 5, content: "클라이빙 3시간", relatedInterest: "유산소", difficulty: 5)
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
                
//                let request: Observable<[RecommendedMissionDTO]> = Observable
//                    .just(self.dummyMissions)
//                    .delay(.seconds(3), scheduler: MainScheduler.instance)
                
                /*
                 let request: Observable<[RecommendedMissionDTO]> = self.missionService
                 .fetchRecommendedMissions(userId: self.userId, interests: self.interests)
                 .asObservable()
                 .map { $0.missions }
                 */
                
//                return request
//                    .do(
//                        onSubscribe: { [weak self] in self?.loadingRelay.accept(true) },
//                        onDispose: { [weak self] in self?.loadingRelay.accept(false) }
//                    )
//                    .catch { [weak self] error in
//                        self?.errorRelay.accept(error.localizedDescription)
//                        return .just([]) // 에러 시 빈 배열로
//                    }
                
                // 2. 3초 딜레이 시뮬레이션 (서버 요청 대기 시간)
                return Observable.just(self.dummyMissions)
                    .delay(.seconds(1), scheduler: MainScheduler.instance) // ★ 3초 뒤에 데이터 방출
                    .do(onNext: { _ in
                        // 3. 데이터가 도착하면 로딩 종료 (스켈레톤 숨기고 데이터 보여주기)
                        loadingSubject.onNext(false)
                    }, onError: { _ in
                        // 에러 발생 시에도 로딩 종료
                        loadingSubject.onNext(false)
                    })
            }
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
