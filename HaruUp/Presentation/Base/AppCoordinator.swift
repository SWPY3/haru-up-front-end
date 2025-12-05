//
//  AppCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/1/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // TODO: 토큰 유무에 따라 Login 및 Home에 따라 분기 처리 - (token 서버에서 나오는 token)
        /// 분기처리 구분
        /// 1. 로그인여부
        /// 2. 온보딩여부
        showLoginFlow()
    }

    private func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            
            self.showOnboardingFlow()
        }
        
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    private func showOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            
            self.showMainTabFlow()
        }
        
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func showMainTabFlow() {
        let mainTabCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        childCoordinators.append(mainTabCoordinator)
        
        mainTabCoordinator.start()
    }
}
