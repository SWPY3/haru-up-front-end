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
    
    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let birthSelectVM = BirthSelectViewModel(coordinator: self)
        let birthSelectVC = BirthSelectViewController(viewModel: birthSelectVM)
        navigationController.pushViewController(birthSelectVC, animated: true)
    }
    
    func showNextFlow(selectedBirth: String) {
        curationData.birthDate = selectedBirth
                print("📦 저장된 데이터 - 생년월일: \(selectedBirth)")
        onFinish?()
    }
    
}
