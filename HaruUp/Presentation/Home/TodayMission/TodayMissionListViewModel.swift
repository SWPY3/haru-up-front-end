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
        let missions: Observable<[MemberMission.MissionDTO]>
        let isLoading: Observable<Bool>
        let errorMessage: Observable<String>
        let missionCompleted: Observable<Void>
    }
    
    private let missionService: MissionServiceProtocol
    private let interestsService: InterestsService
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    // TODO: test용
    private let userId: Int = 4639152463
    
    init(missionService: MissionServiceProtocol, interestsService: InterestsService) {
        self.missionService = missionService
        self.interestsService = interestsService
        // TODO: 이전 화면에서 사용자의 정보(CoreData or Server)를 가져와서 표시
    }
    
    func transform(input: Input) -> Output {
        let loadingSubject = BehaviorSubject<Bool>(value: false)
        let errorSubject = PublishSubject<String>()
        
        // 화면 진입 + 새로고침을 하나의 트리거
        let trigger = Observable.merge(input.viewDidLoad, input.refreshTap)
        
        let missions: Observable<[MemberMission.MissionDTO]> = trigger
               .flatMapLatest { [weak self] _ -> Observable<[MemberMission.MissionDTO]> in
                   guard let self else { return .empty() }

                   loadingSubject.onNext(true)
                   
                   return self.resolveMemberInterestId()
                       .flatMap { id in
                           self.missionService.fetchRecommendedMissions(memberInterestId: id)
                       }
                       .asObservable()
                       .map { $0.data.missions }
                       .do(
                        onNext: { _ in loadingSubject.onNext(false) },
                        onError: { _ in loadingSubject.onNext(false) }
                       )
                       .catch { err in
                           errorSubject.onNext(err.localizedDescription)
                           return .just([])
                       }
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
    
    private func resolveMemberInterestId() -> Single<Int> {
        // UserDefaults에 저장된 값 사용
        if let saved = interestsService.selectedMemberInterestId {
            return .just(saved)
        }

        // 없을 시 서버에 요청 후 데이터 값 저장
        return interestsService.fetchInterests()
            .map { [weak self] dto in
                guard let id = dto.interests.first?.memberInterestId else {
                    throw NSError(domain: "Interests",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "관심사가 없습니다."])
                }
                
                self?.interestsService.selectedMemberInterestId = id // UserDefaults 값 업데이트
                return id
            }
    }

}
