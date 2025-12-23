//
//  BirthSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit



final class BirthSelectCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let birthSelectVM = BirthSelectViewModel(coordinator: self)
        let birthSelectVC = BirthSelectViewController(viewModel: birthSelectVM)
        navigationController.pushViewController(birthSelectVC, animated: true)
    }
    
    func showInterestSelectFlow(selectedBirth: String) {
        curationData.birthDate = selectedBirth
        let interestSelectCoordinator = InterestSelectCoordinator(navigationController: navigationController, curationData: curationData)
        
        curationData.birthDate = selectedBirth
        
        interestSelectCoordinator.onFinish = { [weak self, weak interestSelectCoordinator] curationData in
            if let coordinator = interestSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(interestSelectCoordinator)
        interestSelectCoordinator.start()
    }
    
}
