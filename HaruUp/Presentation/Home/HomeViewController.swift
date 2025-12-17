//
//  RegistrationViewController.swift
//  HaruUp
//
//  Created by 하다현 on 11/27/25.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: HomeViewModel
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    var onSelectTodayMission: (() -> Void)? // Coordinator와의 연결은 단순히 클로저 사용
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(TodayMissionTableViewCell.self, forCellReuseIdentifier: TodayMissionTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        
        return tableView
    }()
    
    private let headerView = HomeHeaderView()
    
    // MARK: - LifeCycle
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.tableHeaderView = headerView
        tableView.sectionHeaderTopPadding = 0
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func bind() {
        let input = HomeViewModel.Input(
            viewDidAppear: viewDidAppearSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.showTodayMissionFlow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.onSelectTodayMission?()
            })
            .disposed(by: disposeBag)
    }
}
