//
//  NicknameSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/19/25.
//

import UIKit

final class NicknameSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let nicknameSelectVM = NicknameSelectViewModel(coordinator: self)
        let nicknameSelectVC = NicknameSelectViewController(viewModel: nicknameSelectVM)
        navigationController.pushViewController(nicknameSelectVC, animated: true)
    }
    
    func showJobSelectFlow(selectedNickname: String) {
        curationData.nickname = selectedNickname
        
        let jobSelectCoordinator = JobSelectCoordinator(
            navigationController: navigationController,
            curationData: curationData
        )
        print("📦 저장된 데이터 - 닉네임: \(selectedNickname)")
        
        childCoordinators.append(jobSelectCoordinator)
        jobSelectCoordinator.start()
    }
    
}
