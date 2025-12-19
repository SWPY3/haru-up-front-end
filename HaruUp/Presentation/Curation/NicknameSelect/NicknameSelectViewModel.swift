//
//  NicknameSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/19/25.
//

import UIKit
import RxSwift
import RxCocoa

final class NicknameSelectViewModel {
    
    struct Input {
        let nicknameInput: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isValid: Driver<Bool>
        let formattedNickname: Driver<String>
    }
    
    private weak var coordinator: NicknameSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let currentNickname = BehaviorRelay<String>(value: "")
    private let maxLength = 10  // 닉네임 최대 길이
    
    init(coordinator: NicknameSelectCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        input.nicknameInput
            .bind(to: currentNickname)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentNickname)
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                let trimmedNickname = nickname.trimmingCharacters(in: .whitespaces)
                print("🔵 다음 버튼 탭됨 - 닉네임: \(trimmedNickname)")
                
                
                if trimmedNickname.count >= 2 && trimmedNickname.count <= 10 {
                    print("✅ 닉네임 입력 완료")
                    self.coordinator?.showJobSelectFlow(selectedNickname: trimmedNickname)
                }
            })
            .disposed(by: disposeBag)
        
        let isValid = input.nicknameInput
            .map { nickname in
                let trimmed = nickname.trimmingCharacters(in: .whitespaces)
                return trimmed.count >= 2 && trimmed.count <= 10
            }
            .asDriver(onErrorJustReturn: false)
        
        // 닉네임 포맷팅 (최대 길이 제한)
        let formattedNickname = input.nicknameInput
            .map { [weak self] nickname -> String in
                guard let self = self else { return nickname }
                return String(nickname.prefix(self.maxLength))
            }
            .asDriver(onErrorJustReturn: "")
        
        return Output(
            isValid: isValid,
            formattedNickname: formattedNickname
        )
    }
}
