//
//  MissionBottomSheetViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/26/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MissionBottomSheetViewModel {
    
    struct Input {
        let completeTap: Observable<Void>
        let deleteTap: Observable<Void>
    }
    
    struct Output {
        let missionTitle: Driver<String>
        let missionExp: Driver<Int>
        let dismiss: Signal<Void>
        let complete: Signal<Bool>
        let errorMessage: Signal<String>
    }
    
    private let mission: Mission
    private let missionService: MissionServiceProtocol
    private let disposeBag = DisposeBag()
    
    // 외부(Coordinator)에서 데이터와 서비스를 주입받음
    init(mission: Mission, missionService: MissionServiceProtocol) {
        self.mission = mission
        self.missionService = missionService
    }
    
    func transform(input: Input) -> Output {
        let dismissRelay = PublishRelay<Void>()
        let completeRelay = PublishRelay<Bool>()
        let errorRelay = PublishRelay<String>()
        
        input.completeTap
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<MemberMission.MissionStatusResponseDTO> in
                return owner.missionService.setMissionStatus(
                    id: owner.mission.id,
                    status: MissionStatus.completed.rawValue
                )
                .asObservable()
                .catch { error in
                    errorRelay.accept("미션 완료 실패: \(error.localizedDescription)")
                    return .empty()
                }
            }
            .bind(onNext: { _ in
                completeRelay.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.deleteTap
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<MemberMission.MissionStatusResponseDTO> in
                return owner.missionService.setMissionStatus(
                    id: owner.mission.id,
                    status: MissionStatus.inactive.rawValue
                )
                .asObservable()
                .catch { error in
                    errorRelay.accept("미션 삭제 실패: \(error.localizedDescription)")
                    return .empty()
                }
            }
            .bind(onNext: { _ in
                dismissRelay.accept(())
            })
            .disposed(by: disposeBag)
            
        return Output(
            missionTitle: Driver.just(mission.title),
            missionExp: Driver.just(mission.exp),
            dismiss: dismissRelay.asSignal(),
            complete: completeRelay.asSignal(),
            errorMessage: errorRelay.asSignal()
        )
    }
}
