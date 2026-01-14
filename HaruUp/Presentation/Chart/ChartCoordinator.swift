//
//  ChartCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ChartCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    private let disposeBag = DisposeBag()
    private let viewModel: ChartViewModel
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.viewModel = ChartViewModel()
    }
    
    func start() {
        let chartRankingVC = ChartRankingViewController(viewModel: viewModel)
        navigationController.setViewControllers([chartRankingVC], animated: true)
        
        // 초기 화면 설정 및 데이터 변화 감지
//        output.hasData
//            .drive(onNext: { [weak self] hasData in
//                self?.switchViewController(hasData: hasData)
//            })
//            .disposed(by: disposeBag)
    }
    // MARK: - Private Methods
//    private func switchViewController(hasData: Bool) {
//        if hasData {
//            showRankingViewController()
//        } else {
//            showEmptyViewController()
//        }
//    }
//    
//    private func showRankingViewController() {
//        // 이미 RankingVC가 표시 중이면 중복 방지
//        if let topVC = navigationController.topViewController,
//           topVC is ChartRankingViewController {
//            return
//        }
//        
//        let chartRankingVC = ChartRankingViewController(viewModel: viewModel)
//        navigationController.setViewControllers([chartRankingVC], animated: true)
//    }
//    
//    private func showEmptyViewController() {
//        // 이미 EmptyVC가 표시 중이면 중복 방지
//        if let topVC = navigationController.topViewController,
//           topVC is ChartEmptyViewController {
//            return
//        }
//        
//        let chartEmptyVC = ChartEmptyViewController(viewModel: viewModel)
//        navigationController.setViewControllers([chartEmptyVC], animated: true)
//    }
}
