//
//  CharcterSelectCompleteCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 4/15/26.
//

import UIKit


final class CharcterSelectCompleteCoordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController,) {
        self.navigationController = navigationController
    }
    
    var onFinish: ((CurationData) -> Void)?
    
    func start() {
        
    }
}


