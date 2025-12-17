//
//  CreateProfileCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit
import RxSwift
import RxCocoa


final class CreateProfileCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    var onFinish: (() -> Void)?
    
    private let viewModel = CreateProfileViewModel()
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        showCharacterSelectFlow()
    }
    
    private func showCharacterSelectFlow() {
        let vc = CharacterSelectViewController(viewModel: viewModel)
        
        vc.onNext = { [weak self] selectedCharacter in
            self?.curationData.characterId = selectedCharacter
            print("📦 저장된 데이터 - 캐릭터: \(selectedCharacter)")
            self?.showNicknameSelectFlow(selectedCharacter: selectedCharacter)
        }
        
        navigationController.setViewControllers([vc], animated: true)
    }
    
    private func showNicknameSelectFlow(selectedCharacter: Int) {
        let vc = NicknameSelectViewController(selectedCharacter: selectedCharacter, viewModel: viewModel)
        
        vc.onFinish = { [weak self] character, nickname in
            // TODO: 서버에 프로필 정보 전송
            print("🎉 프로필 생성 완료")
            print("   캐릭터: \(character)")
            print("   닉네임: \(nickname)")
            
            self?.curationData.nickname = nickname
            print("📦 저장된 데이터 - 닉네임: \(nickname)")
            
            // 로컬 저장 (필요시)
            // UserDefaults.standard.set(character, forKey: "selectedCharacter")
            // UserDefaults.standard.set(nickname, forKey: "nickname")
            
        }
        
        viewModel.shouldComplete
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("현재 닉ㅇ네임: \(self?.curationData.nickname ?? "없어")")
                self?.onFinish?()
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(vc, animated: true)
    }
}
