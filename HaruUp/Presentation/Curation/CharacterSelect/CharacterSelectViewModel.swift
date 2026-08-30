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
        /// characterId → 이름. 서버에서 받아 화면에 표시한다.
        let characterNames: Driver<[Int: String]>
    }
    
    private weak var coordinator: CharacterSelectCoordinator?
    private let characterService: CharacterService
    private let disposeBag = DisposeBag()
    
    private let currentCharacter = BehaviorRelay<Int?>(value: nil)
    private let characterNamesRelay = BehaviorRelay<[Int: String]>(value: [:])
    
    init(coordinator: CharacterSelectCoordinator, characterService: CharacterService = CharacterService()) {
        self.coordinator = coordinator
        self.characterService = characterService
        loadCharacterNames()
    }

    /// 캐릭터 이름을 서버에서 받아온다.
    /// 실패하면 relay 를 비워 둔 채로 두고, 화면이 앱에 있는 기본 이름을 그대로 쓴다.
    /// 이름을 못 받았다고 캐릭터 선택 자체를 막을 이유는 없다.
    private func loadCharacterNames() {
        characterService.characterList()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] characters in
                    let names = characters.reduce(into: [Int: String]()) { dict, character in
                        if let name = character.name, !name.isEmpty {
                            dict[character.id] = name
                        }
                    }
                    self?.characterNamesRelay.accept(names)
                },
                onFailure: { _ in }
            )
            .disposed(by: disposeBag)
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
            isValid: isValid,
            selectedCharacter: selectedCharacter,
            characterNames: characterNamesRelay.asDriver()
        )
    }
}
