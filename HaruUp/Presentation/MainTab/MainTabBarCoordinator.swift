//
//  MainTabBarCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/2/25.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    let curationData: CurationData
    let appCoordinator: AppCoordinator
    
    init(navigationController: UINavigationController, curationData: CurationData, appCoordinator: AppCoordinator) {
        self.navigationController = navigationController
        self.curationData = curationData
        self.appCoordinator = appCoordinator
    }
    
    func start() {
        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        homeNav.tabBarItem = UITabBarItem(title: "홈", image: nil, selectedImage: nil) // 현재 이미지는 없게 표시
        
        let historyNav = UINavigationController()
        let historyCoordinator = HistoryCoordinator(navigationController: historyNav)
        childCoordinators.append(historyCoordinator)
        historyCoordinator.start()
        historyNav.tabBarItem = UITabBarItem(title: "히스토리", image: nil, selectedImage: nil) // 현재 이미지는 없게 표시
        
        let chartNav = UINavigationController()
        let chartCoordinator = ChartCoordinator(navigationController: chartNav)
        childCoordinators.append(chartCoordinator)
        chartCoordinator.start()
        chartNav.tabBarItem = UITabBarItem(title: "추천", image: nil, selectedImage: nil) // 현재 이미지는 없게 표시
        
        let myPageNav = UINavigationController()
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNav, curationData: curationData)
        childCoordinators.append(myPageCoordinator)
        
        myPageCoordinator.onFinish = { [weak self] in
            self?.appCoordinator.showLoginFlow()
        }
        
        myPageCoordinator.start()
        myPageNav.tabBarItem = UITabBarItem(title: "마이페이지", image: nil, selectedImage: nil) // 현재 이미지는 없게 표시
        
        let container = MainTabBarController(tabs: [homeNav, historyNav, chartNav, myPageNav])
        
        navigationController.setViewControllers([container], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}
