//
//  MyPageViewCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

final class MyPageViewCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    let curationData: CurationData
    var onFinish: (() -> Void)?
    
    // 닉네임 유효성 검사 VM은 Coordinator가 들고 있거나 DI Container에서 가져옴
    // 여기서는 간단히 생성
    private lazy var nicknameServiceVM: NicknameSelectViewModel = {
        // Coordinator를 self로 넘겨야 하지만 순환 참조 주의 (여기선 로직 재사용 목적이므로 nil이나 dummy 사용 가능하나, 구조상 this coordinator를 넘김)
        // 실제로는 별도의 UseCase나 Service로 분리하는 것이 좋음
        return NicknameSelectViewModel(coordinator: NicknameSelectCoordinator(navigationController: navigationController, curationData: curationData))
    }()
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let myPageVM = MyPageViewModel(curationData: curationData)
        let myPageVC = MyPageViewController(viewModel: myPageVM)
        
        myPageVC.onEditProfile = { [weak self] in
            self?.showProfileEdit()
        }
        
        myPageVC.onEditInterest = { [weak self] in
            self?.showInterestEdit()
        }
        
        myPageVC.onNotificationSetting = { [weak self] in
            self?.showNotificationSetting()
        }
        
        myPageVC.onLogout = { [weak self] in
            self?.onFinish?()
        }
        
        myPageVC.onWithdraw = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.setViewControllers([myPageVC], animated: false)
    }
    
    func showProfileEdit() {
        print("=== 프로필 수정 진입 ===")
        
        // 2. ViewModel 주입
        let vm = ProfileEditViewModel(
            nicknameServiceVM: NicknameSelectViewModel(coordinator: NicknameSelectCoordinator(navigationController: navigationController, curationData: curationData))
        )
        
        let vc = ProfileEditViewController(viewModel: vm)
        // 3. Coordinator에서 push
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showInterestEdit() {
        print("=== 관심사 수정 진입 ===")
        
        // ViewModel 생성
        let vm = InterestEditViewModel()
        
        let vc = InterestEditViewController(viewModel: vm)
        // Coordinator에서 push
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showNotificationSetting() {
        print("=== 알림 설정 진입 ===")
        
        let notifiVM = NotificationSettingViewModel()
        
        let notifiVC = NotificationSettingViewController()
        navigationController.pushViewController(notifiVC, animated: true)
    }
}
