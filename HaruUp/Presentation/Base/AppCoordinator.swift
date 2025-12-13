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
    
    private let tokenStorage = TokenStorageService.shared

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // TODO: 토큰 유무에 따라 Login 및 Home에 따라 분기 처리 - (token 서버에서 나오는 token)
        
        let splashCoordinator = SplashCoordinator(navigationController: navigationController)
        childCoordinators.append(splashCoordinator)
        
        splashCoordinator.onFinish = { [weak self, weak splashCoordinator] result in
            guard let self = self else { return }
            
            
            // SplashCoordinator 메모리 정리
            if let splash = splashCoordinator, let index = self.childCoordinators.firstIndex(where: { $0 === splash }) {
                self.childCoordinators.remove(at: index)
            }
            // 분기처리 구분
            switch result {
            case .needLogin:
                showLoginFlow()
            case .onboardingRequired:
                showOnboardingFlow()
            case .onboardingCompleted:
                showMainTabFlow()
            }
        }
        splashCoordinator.start()
    }
        
        

    private func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.onFinish = { [weak self, weak loginCoordinator] loginResult in
            guard let self else { return }
            
            // LoginCoordinator 메모리 정리
            if let coordinator = loginCoordinator,
               let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self.childCoordinators.remove(at: index)
            }
            
            // 로그인 완료 후 온보딩 여부 확인
            if let onboardingCompleted = loginResult.onboardingCompleted, onboardingCompleted {
                self.showMainTabFlow()
            }
            if let onboardingRequired = loginResult.onboardingRequired, onboardingRequired {
                self.showOnboardingFlow()
            }
        }
        
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    private func showOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.onFinish = { [weak self, weak onboardingCoordinator] in
            guard let self = self else { return }
            
            
            if let coordinator = onboardingCoordinator,
               let index = self.childCoordinators.firstIndex(where: {$0 === coordinator}) {
                self.childCoordinators.remove(at: index)
            }
            
            
            // 온보딩 완료시 저장
            TokenStorageService.shared.saveOnboardingCompleted(true)
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
