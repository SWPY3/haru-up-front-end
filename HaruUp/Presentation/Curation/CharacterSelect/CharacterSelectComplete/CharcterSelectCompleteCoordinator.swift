//
//  CharacterSelectCompleteCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 4/15/26.
//

import UIKit


final class CharacterSelectCompleteCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let characterId = curationData.characterId ?? 1
        let characterSelectCompleteVM = CharacterSelectCompleteViewModel(coordinator: self, characterId: characterId)
        let characterSelectCompleteVC = CharacterSelectCompleteViewController(viewModel: characterSelectCompleteVM)
        
        navigationController.pushViewController(characterSelectCompleteVC, animated: true)
    }
    
    
    func showNicknameSelectFlow(selectedCharacter: Int) {
        curationData.characterId = selectedCharacter
        print("📦 저장된 데이터 - 캐릭터: \(selectedCharacter)")

        let curationChatCoordinator = CurationChatCoordinator(
            navigationController: navigationController,
            curationData: curationData
        )

        curationChatCoordinator.onFinish = { [weak self, weak curationChatCoordinator] curationData in
            if let coordinator = curationChatCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }

            self?.onFinish?(curationData)
        }

        childCoordinators.append(curationChatCoordinator)
        curationChatCoordinator.start()
    }
    
}


