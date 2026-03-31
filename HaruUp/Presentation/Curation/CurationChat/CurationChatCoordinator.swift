//
//  CurationChatCoordinator.swift
//  HaruUp
//
//  Created on 2026/03/30.
//

import UIKit

final class CurationChatCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []

    private var curationData: CurationData
    var onFinish: ((CurationData) -> Void)?

    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }

    func start() {
        let characterId = curationData.characterId ?? 1
        let viewModel = CurationChatViewModel(coordinator: self, characterId: characterId)
        let viewController = CurationChatViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func didFinishChat(answers: [String]) {
        // answers 순서:
        // [0] 관심사
        // [1] 관심이 생기게 된 계기
        // [2] 실력 단계 (1~10)
        // [3] 목표 기간
        // [4] 투자 가능 시간
        // [5] 추가 질문

        // 다음 플로우로 이동 (NicknameSelect 등 기존 플로우 연결)
        let nicknameSelectCoordinator = NicknameSelectCoordinator(
            navigationController: navigationController,
            curationData: curationData
        )

        nicknameSelectCoordinator.onFinish = { [weak self, weak nicknameSelectCoordinator] curationData in
            if let coordinator = nicknameSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }

            self?.onFinish?(curationData)
        }

        childCoordinators.append(nicknameSelectCoordinator)
        nicknameSelectCoordinator.start()
    }
}
