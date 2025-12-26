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

    
    private var curationData: CurationData

    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let interestSelectVM = InterestSelectViewModel(coordinator: self)
        let interestSelectVC = InterestSelectViewController(viewModel: interestSelectVM)
        
        navigationController.pushViewController(interestSelectVC, animated: true)
        
    }
    
    func showInterestDetailSelectFlow(selectedInterest: Interest) {
        
        let interestData = InterestData(id: selectedInterest.id, name: selectedInterest.title)
        
        curationData.interest = interestData
        print("📦 저장된 데이터 - 관심사: \(selectedInterest.title), ID: \(selectedInterest.id),,,, \(interestData)")
        
        let interestDetailCoordinator = InterestDetailSelectCoordinator(navigationController: navigationController, selectedInterest: selectedInterest, curationData: curationData)
        
        interestDetailCoordinator.onFinish = { [weak self, weak interestDetailCoordinator] curationData in
            if let coordinator = interestDetailCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(interestDetailCoordinator)
        interestDetailCoordinator.start()
    }
    
    
}
