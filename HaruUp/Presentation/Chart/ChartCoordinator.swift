//
//  ChartCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

final class ChartCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let chartVM = ChartViewModel()
        // 분기 처리 로직
        if chartVM.hasData {
            // 1. 데이터가 있으면 랭킹 화면
            let chartRankingVC = ChartRankingViewController(viewModel: chartVM)
            navigationController.setViewControllers([chartRankingVC], animated: false)
        } else {
            // 2. 데이터가 없으면 대기 화면
            let chartEmptyVC = ChartEmptyViewController(viewModel: chartVM)
            navigationController.setViewControllers([chartEmptyVC], animated: false)
        }
    }
}
