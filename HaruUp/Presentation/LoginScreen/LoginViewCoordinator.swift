//
//  LoginViewCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/1/25.
//

import UIKit

final class LoginCoordinator: Coordinator {
    // 보통 바꿀 일 없으니 let 추천
    let navigationController: UINavigationController
    
    // child는 기본적으로 빈 배열로 시작
    var childCoordinators: [any Coordinator] = []
    
    var onFinish: (() -> Void)? // 로그인 완료 후 화면 이동
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authService = AuthService()
        let loginVM = LoginViewModel(authService: authService)
        let loginVC = LoginViewController(viewModel: loginVM)
        
        loginVC.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.setViewControllers([loginVC], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}
