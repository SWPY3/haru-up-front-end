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
        childCoordinators.append(birthSelectCoordinator)
        birthSelectCoordinator.start()
    }
}
