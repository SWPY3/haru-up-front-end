//
//  JobSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit


final class JobSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []

    private var curationData: CurationData
    
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let jobSelectVM = JobSelectViewModel(coordinator: self)
        let jobSelectVC = JobSelectViewController(viewModel: jobSelectVM)
        
        navigationController.pushViewController(jobSelectVC, animated: true)
    }
    
    func showjobDetailFlow(selectedJob: String) {
        let jobDetailCoordinator = JobDetailSelectCoordinator(
            navigationController: navigationController,
            selectedJob: selectedJob,
            curationData: curationData
        )
        curationData.job = selectedJob
        print("📦 저장된 데이터 - 직업: \(selectedJob)")
        
        childCoordinators.append(jobDetailCoordinator)
        jobDetailCoordinator.start()
    }
}
