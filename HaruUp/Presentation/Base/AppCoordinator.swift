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
    private var curationData = CurationData()

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
            // 로그인 완료 후 분기 처리 개선
            print("🔍 로그인 결과 - onboardingCompleted: \(loginResult.onboardingCompleted)")
            
            // 로그인 완료 후 온보딩 여부 확인
            if loginResult.onboardingCompleted {
                print("✅ 온보딩 완료 → 홈 화면으로 이동")
                self.showMainTabFlow()
            } else {
                print("⚠️ 온보딩 필요 → 온보딩 화면으로 이동")
                self.showOnboardingFlow()
            }
        }
        
        loginCoordinator.gotoHome = { [weak self] in
            guard let self else { return }
            
            self.showMainTabFlow()
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
            
            self.showCurationFlow()
        }
        
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func showCurationFlow() {
        let characterSelectCoordinator = CharacterSelectCoordinator(navigationController: navigationController,
                                                                    curationData: curationData)
        
        characterSelectCoordinator.onFinish = { [weak self, weak characterSelectCoordinator] curationData in
            print("📦 ===== 최종 수집된 데이터 ===== 📦")
            print("캐릭터 ID: \(curationData.characterId ?? -1)")
            print("닉네임: \(curationData.nickname ?? "없음")")
            print("직업: \(curationData.job?.jobName ?? "없음")")
            print("세부 직무: \(curationData.jobDetail?.jobDetailName ?? "없음")")
            print("성별: \(curationData.gender ?? "없음")")
            print("생년월일: \(curationData.birthDate ?? "없음")")
            print("관심사: \(curationData.interest?.name ?? "없음")")
            print("세부 관심사: \(curationData.interestDetail?.name ?? "없음")")
            print("목표: \(curationData.goal?.name ?? "없음")")
            print("📦 ========================== 📦")
            
            if let coordinator = characterSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
                print("🗑️ CharacterSelectCoordinator 제거됨 (남은 자식: \(self?.childCoordinators.count ?? 0))")
            }
            self?.showLoadingFlow()
        }
        
        childCoordinators.append(characterSelectCoordinator)
        characterSelectCoordinator.start()
    }
    
    
    private func showLoadingFlow() {
        let loadingCoordinator = LoadingCoordinator(navigationController: navigationController, curationData: curationData)
        
        loadingCoordinator.onFinsh = { [weak self, weak loadingCoordinator] in
            guard let self = self else { return }
            
            if let coordinator = loadingCoordinator,
               let index = self.childCoordinators.firstIndex(where: {$0 === coordinator}) {
                self.childCoordinators.remove(at: index)
            }
            
            self.showLoadingCompleteFlow()
        }
        childCoordinators.append(loadingCoordinator)
        
        loadingCoordinator.start()
    }
    
    private func showLoadingCompleteFlow() {
        let loadingCompleteCoordinator = LoadingCompleteCoordinator(navigationController: navigationController)
        childCoordinators.append(loadingCompleteCoordinator)
        
        loadingCompleteCoordinator.start()
    }
    
    private func showMainTabFlow() {
        let mainTabCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        childCoordinators.append(mainTabCoordinator)
        
        mainTabCoordinator.start()
    }
}
