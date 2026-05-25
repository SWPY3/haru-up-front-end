//
//  CurationChatCoordinator.swift
//  HaruUp
//
//  Created on 2026/03/30.
//

import UIKit

final class CurationChatCoordinator: Coordinator {
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
        let viewModel = CurationChatViewModel(
            coordinator: self,
            characterId: characterId,
            chatbotService: ChatbotService()
        )
        
        let viewController = CurationChatViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func didFinishChat(missions: [ChatbotMissionDto], nickname: String) {
        curationData.nickname = nickname
        TokenStorageService.shared.saveOnboardingCompleted(true)
        onFinish?(curationData)
    }
    
}
