//
//  CharacterSelectCompleteViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 4/15/26.
//

import UIKit
import RxSwift
import RxCocoa

final class CharacterSelectCompleteViewModel {
    enum Step {
        case welcome
        case guide
    }
    
    struct Input {
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let currentStep: Driver<Step>
        let characterId: Int
    }
    
    private let stepRelay = BehaviorRelay<Step>(value: .welcome)
    private weak var coordinator: CharacterSelectCompleteCoordinator?
    private let characterId: Int
    private let disposeBag = DisposeBag()
    
    init(coordinator: CharacterSelectCompleteCoordinator, characterId: Int) {
        self.coordinator = coordinator
        self.characterId = characterId
    }
    
    func transform(input: Input) -> Output {
        input.nextButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.stepRelay.value == .welcome {
                    self.stepRelay.accept(.guide)
                } else {
                    // 시작하기 버튼 클릭 시 다음 Flow로 이동
                    self.coordinator?.showNicknameSelectFlow(selectedCharacter: self.characterId)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            currentStep: stepRelay.asDriver(),
            characterId: characterId
        )
    }
}
