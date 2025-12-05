//
//  OnboardingCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/2/25.
//

import UIKit

final class OnboardingCoordinator: Coordinator {

    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    var onFinish: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let onboardingVM = OnboardingViewModel()
        let onboardingVC = OnboardingViewController(viewModel: onboardingVM)
        
        onboardingVC.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.setViewControllers([onboardingVC], animated: true)
    }
}
