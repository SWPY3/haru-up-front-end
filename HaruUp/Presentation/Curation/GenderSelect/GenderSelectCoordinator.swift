//
//  GenderSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class GenderSelectCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    
    func start() {
        let genderSelectVM = GenderSelectViewModel(coordinator: self)
        let genderSelectVC = GenderSelectViewController(viewModel: genderSelectVM)
        navigationController.pushViewController(genderSelectVC, animated: true)
    }
    
    func showBirthSelectFlow(selectedGender: String) {
        print("선택된 성별: \(selectedGender)")
        
        let birthSelectCoordinator = BirthSelectCoordinator(navigationController: navigationController, curationData: curationData)
        
        curationData.gender = selectedGender
        
        birthSelectCoordinator.onFinish = { [weak self, weak birthSelectCoordinator] curationData in
            if let coordinator = birthSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(birthSelectCoordinator)
        birthSelectCoordinator.start()
    }
}
