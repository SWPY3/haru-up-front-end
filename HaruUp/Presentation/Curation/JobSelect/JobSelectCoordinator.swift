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
    
    func showjobDetailFlow(selectedJob: Job) {
        let jobDetailSelectCoordinator = JobDetailSelectCoordinator(
            navigationController: navigationController,
            selectedJob: selectedJob,
            curationData: curationData
        )
        curationData.job = selectedJob
        print("📦 저장된 데이터 - 직업: \(selectedJob.jobName), ID: \(selectedJob.id)")
        
        if selectedJob.jobName == "자영업" {
            showGenderSelectFlow()
            return 
        }
        
        jobDetailSelectCoordinator.onFinish = { [weak self, weak jobDetailSelectCoordinator] curationData in
            if let coordinator = jobDetailSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(jobDetailSelectCoordinator)
        jobDetailSelectCoordinator.start()
    }
    
    
    func showGenderSelectFlow() {
        let genderSelectCoordinator = GenderSelectCoordinator(
            navigationController: navigationController,
            curationData: curationData)
        
        genderSelectCoordinator.onFinish = { [weak self, weak genderSelectCoordinator] curationData in
            if let coordinator = genderSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        
        childCoordinators.append(genderSelectCoordinator)
        
        genderSelectCoordinator.start()
    }
}
