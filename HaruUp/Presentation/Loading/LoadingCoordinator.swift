//
//  LoadingCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/23/25.
//

import UIKit


final class LoadingCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    var onFinsh: (() -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let loadingVM = LoadingViewModel()
        let loadingVC = LoadingViewController(curationData: curationData, viewModel: loadingVM, coordinator: self)
        
        navigationController.setViewControllers([loadingVC], animated: true)
    }
    
    
    func showLoadingComplete() {
        print("🎬 LoadingCompleteViewController로 전환")
        let loadingCompleteVC = LoadingCompleteViewController()
        navigationController.setViewControllers([loadingCompleteVC], animated: true)
    }
}
