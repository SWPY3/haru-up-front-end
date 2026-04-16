//
//  CharacterSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/19/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CharacterSelectViewModel {
    struct Input {
        let characterSelected: Observable<Int>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isValid: Driver<Bool>
        let selectedCharacter: Driver<Int?>
    }
    
    private weak var coordinator: CharacterSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentCharacter = BehaviorRelay<Int?>(value: nil)
    
    init(coordinator: CharacterSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    
    func transform(input: Input) -> Output {
        input.characterSelected
            .map { $0 as Int? }
            .bind(to: currentCharacter)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentCharacter)
            .subscribe(onNext: { [weak self] characterIndex in
                print("🔵 다음 버튼 탭됨 - 선택된 캐릭터 인덱스: \(characterIndex ?? -1)")
                guard let character = characterIndex else {
                    print("❌ 캐릭터가 선택되지 않았습니다.")
                    return
                }
                
                print("✅ 캐릭터 선택 완료 - 인덱스: \(character)")
                self?.coordinator?.showCharacterSelectCompleteFlow(selectedCharacter: character)
                print("🔵 CharacterSelectCompleteCoordinator 호출됨")
            })
            .disposed(by: disposeBag)
        
        // 캐릭터 선택 여부 검사
        let isValid = input.characterSelected
            .map{ _ in true }
            .asDriver(onErrorJustReturn: false)
        
        let selectedCharacter = currentCharacter
            .asDriver()
        
        return Output(
            isValid: isValid, selectedCharacter: selectedCharacter
        )
    }
}
