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
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let characterSelectVM = CharacterSelectViewModel(coordinator: self)
        let characterSelectVC = CharacterSelectViewController(viewModel: characterSelectVM)
        navigationController.pushViewController(characterSelectVC, animated: true)
    }
    
    func showCharacterSelectCompleteFlow(selectedCharacter: Int) {
        curationData.characterId = selectedCharacter
        print("📦 저장된 데이터 - 캐릭터: \(selectedCharacter)")

        let characterSelectCompleteCoordinator = CharacterSelectCompleteCoordinator(
            navigationController: navigationController, curationData: curationData
        )

        characterSelectCompleteCoordinator.onFinish = { [weak self, weak characterSelectCompleteCoordinator] curationData in
            if let coordinator = characterSelectCompleteCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }

            self?.onFinish?(curationData)
        }

        childCoordinators.append(characterSelectCompleteCoordinator)
        characterSelectCompleteCoordinator.start()
    }
    

}
