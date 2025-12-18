//
//  InterestSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class InterestSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    var onFinish: (() -> Void)?
    
    private var curationData: CurationData
    
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let interestSelectVM = InterestSelectViewModel(coordinator: self)
        let interestSelectVC = InterestSelectViewController(viewModel: interestSelectVM)
        
        navigationController.pushViewController(interestSelectVC, animated: true)
        
    }
    
    func showInterestDetailSelectFlow(selectedInterest: String) {
        curationData.interest = selectedInterest
        print("📦 저장된 데이터 - 관심사: \(selectedInterest)")
        
        let interestDetailCoordinator = InterestDetailSelectCoordinator(navigationController: navigationController, selectedInterest: selectedInterest, curationData: curationData)
        
        childCoordinators.append(interestDetailCoordinator)
        interestDetailCoordinator.start()
    }
    
    
}
