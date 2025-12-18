//
//  GenderSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa


final class GenderSelectViewModel {
    struct Input {
        let genderSelected: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let genders: Driver<[String]>
        let selectedGender: Driver<String?>
    }
    
    private weak var coordinator: GenderSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    private let genderList = BehaviorRelay<[String]>(value: [
        "남성",
        "여성"
    ])
    
    
    init(coordinator: GenderSelectCoordinator) {
            self.coordinator = coordinator
        }
    
    private let currentSelectedGender = BehaviorRelay<String?>(value: nil)
    
    func transform(input: Input) -> Output {
        input.genderSelected
            .bind(to: currentSelectedGender)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentSelectedGender)
            .subscribe(onNext: { [weak self] selectedGender in
                print("🔵 다음 버튼 탭됨")
                print("🔵 선택된 성별: \(selectedGender ?? "없음")")
                guard let selectedGender = selectedGender else {
                    print("성별을 선택해주세요.")
                    return
                }
                print("🔵 Coordinator 호출 시작")
                self?.coordinator?.showBirthSelectFlow(selectedGender: selectedGender)
                print("🔵 Coordinator 호출 완료")
            })
            .disposed(by: disposeBag)
        
        return Output(
            genders: genderList.asDriver(),
            selectedGender: currentSelectedGender.asDriver()
            )
    }
}
