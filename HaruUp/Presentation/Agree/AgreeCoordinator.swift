//
//  AgreeCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 1/15/26.
//

import UIKit
import SafariServices

final class AgreeCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    var onFinish: (() -> Void)?
    var onBack: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let agreeVM = AgreeViewModel()
        let agreeVC = AgreeViewController(viewModel: agreeVM)
        
        agreeVC.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        agreeVC.onBack = { [weak self] in
            self?.onBack?()
        }
        
        agreeVC.onTermDetailRequest = { [weak self] urlString in
            self?.openWebView(url: urlString)
        }
        
        navigationController.pushViewController(agreeVC, animated: true)
    }
    
    private func openWebView(url: String) {
        guard let url = URL(string: url) else { return }
        
        // SFSafariViewController는 별도의 네비게이션 스택 없이 모달로 띄우는 것이 일반적입니다.
        let safariVC = SFSafariViewController(url: url)
        // 모달로 띄우기
        navigationController.present(safariVC, animated: true, completion: nil)
    }
}
