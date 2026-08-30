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
    
    
    /// 챗봇으로 바로 넘어가지 않고 AI 성격 선택을 먼저 거친다.
    /// 성격 선택이 끝나면 그 코디네이터가 이어서 챗봇을 시작한다.
    func showCurationChatFlow(selectedCharacter: Int) {
        curationData.characterId = selectedCharacter
        print("📦 저장된 데이터 - 캐릭터: \(selectedCharacter)")

        let personalitySelectCoordinator = PersonalitySelectCoordinator(
            navigationController: navigationController,
            curationData: curationData
        )

        personalitySelectCoordinator.onFinish = { [weak self, weak personalitySelectCoordinator] curationData in
            if let coordinator = personalitySelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }

            self?.onFinish?(curationData)
        }

        childCoordinators.append(personalitySelectCoordinator)
        personalitySelectCoordinator.start()
    }
    
}


