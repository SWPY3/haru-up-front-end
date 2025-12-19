//
//  CharacterSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/19/25.
//

import UIKit


final class CharacterSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let characterSelectVM = CharacterSelectViewModel(coordinator: self)
        let characterSelectVC = CharacterSelectViewController(viewModel: characterSelectVM)
                navigationController.pushViewController(characterSelectVC, animated: true)
    }
    
    func showNicknameSelectFlow(selectedCharacter: Int) {
            curationData.characterId = selectedCharacter
            let nicknameSelectCoordinator = NicknameSelectCoordinator(
                navigationController: navigationController,
                curationData: curationData
            )
            
            childCoordinators.append(nicknameSelectCoordinator)
            nicknameSelectCoordinator.start()
        }
}
