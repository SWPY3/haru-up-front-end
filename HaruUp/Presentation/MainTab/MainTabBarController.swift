//
//  MainTabBarController.swift
//  HaruUp
//
//  Created by 조영현 on 12/2/25.
//

import UIKit

final class MainTabBarController: UIViewController {
    
    private let tabs: [UIViewController]
    
    private let tabBarContentHeight: CGFloat = 60
    private var tabBarHeightConstraint: NSLayoutConstraint? // tabBar의 높이를 safeArea에 맞춰서 동적으로 수정하기 위해 별도로 구현
    
    private lazy var mainTabBarView: MainTabBarView = {
        let view = MainTabBarView()
        view.onSelect = { [weak self] tab in
            self?.selectTab(tab)
        }
        
        return view
    }()
    
    private var currentViewController: UIViewController?
    
    // 현재 선택된 탭 추적
    private var currentTab: MainTab = .home
    
    var selectedIndex: Int {
        get {
            return currentTab.rawValue
        }
        set {
            guard newValue >= 0, newValue < tabs.count,
                  let tab = MainTab(rawValue: newValue) else { return }
            selectTab(tab)
        }
    }
    
    init(tabs: [UIViewController]) {
        self.tabs = tabs
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        selectTab(.home)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateTabBarLayout()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        
        configureTabBar()
    }
    
    private func configureTabBar() {
        view.addSubview(mainTabBarView)
        mainTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // 기본 높이로 설정
        tabBarHeightConstraint = mainTabBarView.heightAnchor.constraint(equalToConstant: tabBarContentHeight)
        tabBarHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            mainTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateTabBarLayout() {
        let safeAreaBottom = view.safeAreaInsets.bottom
        let totalTabBarHeight = tabBarContentHeight + safeAreaBottom
        
        tabBarHeightConstraint?.constant = totalTabBarHeight
        
        // 해당 코드 적용으로 TabBar를 사용하는 화면에서 bottom에는 safeAreaLayoutGuide.bottomAnchor로 UI를 연결해야함.
        tabs.forEach { vc in
            vc.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarContentHeight, right: 0)
        }
    }
    
    private func selectTab(_ tab: MainTab) {
        let selectedIndex = tab.rawValue
        guard selectedIndex >= 0, selectedIndex < tabs.count else { return }
        
        let targetViewController = tabs[selectedIndex]
        
        if currentViewController == targetViewController {
            return
        }
        
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(targetViewController)
        view.insertSubview(targetViewController.view, belowSubview: mainTabBarView)
        targetViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            targetViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            targetViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            targetViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            targetViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        targetViewController.didMove(toParent: self)
        
        currentViewController = targetViewController
        currentTab = tab
        mainTabBarView.setSelected(tab)
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        
        UIView.animate(withDuration: duration) {
            self.mainTabBarView.alpha = hidden ? 0 : 1
            self.mainTabBarView.transform = hidden
                ? CGAffineTransform(translationX: 0, y: self.tabBarContentHeight)
                : .identity
        }
    }
    
    func selectTab(at index: Int) {
        selectedIndex = index
    }
    
    func selectMainTab(_ tab: MainTab) {
        selectTab(tab)
    }
}
