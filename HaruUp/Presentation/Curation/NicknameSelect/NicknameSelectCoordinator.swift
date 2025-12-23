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
    var onFinish: ((CurationData) -> Void)?
    
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
        
        jobSelectCoordinator.onFinish = { [weak self, weak jobSelectCoordinator] curationData in
            if let coordinator = jobSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(jobSelectCoordinator)
        jobSelectCoordinator.start()
    }
    
}
