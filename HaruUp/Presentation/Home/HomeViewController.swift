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
    private let viewDidLoadRelay = PublishRelay<Void>() // PublishSubject에서 PublishRelay로 변경.
    private let viewDidAppearRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    var onSelectTodayMission: (() -> Void)? // Coordinator와의 연결은 단순히 클로저 사용
    var onShowBottomSheet: ((Mission) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.bounces = false
        // bottom 여백
        tableView.contentInset.bottom = 40
        tableView.verticalScrollIndicatorInsets.bottom = 40
        
        tableView.register(EmptyMissionCell.self, forCellReuseIdentifier: EmptyMissionCell.identifier)
        tableView.register(MissionTableViewCell.self, forCellReuseIdentifier: MissionTableViewCell.identifier)
        tableView.register(AddMissionTableViewCell.self, forCellReuseIdentifier: AddMissionTableViewCell.identifier)
        
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
        
        viewDidLoadRelay.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearRelay.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderHeight()
    }
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.tableHeaderView = headerView
        tableView.sectionHeaderTopPadding = 28 // Section Header와 TableView Header의 간격
        
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateTableHeaderHeight() {
        guard let header = tableView.tableHeaderView else { return }

        let targetSize = CGSize(width: tableView.bounds.width, height: 0)
        /// systemLayoutSizeFitting를 통해 뷰 내부의 제약 조건 확인 후 설정
        let height = header.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height

        if header.frame.height != height {
            var frame = header.frame
            frame.size.height = height
            header.frame = frame // 헤더 뷰의 프레임 수정
            
            tableView.tableHeaderView = header // 테이블뷰로 다시 할당
        }
    }
    
    private func bind() {
        let input = HomeViewModel.Input(
            viewDidLoad: viewDidLoadRelay.asObservable(),
            viewDidAppear: viewDidAppearRelay.asObservable(),
        )
        
        let output = viewModel.transform(input: input)
        
        output.rows
            .asObservable()
            .bind(to: tableView.rx.items) { [weak self] (tableView: UITableView, row: Int, item: TodayMissionRow) -> UITableViewCell in
                guard let self else { return UITableViewCell() }
                
                switch item {
                case .empty:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyMissionCell.identifier, for: IndexPath(row: row, section: 0)) as? EmptyMissionCell else { return UITableViewCell() }
                    
                    cell.onTapAdd = { [weak self] in
                        // TODO: Mission 추가 생성 기능
                        print("Add Button 동작")
                    }
                    
                    return cell
                    
                case .mission(let mission):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MissionTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as? MissionTableViewCell else { return UITableViewCell() }
                    
                    cell.configure(mission: mission)
                    cell.onTapSetting = { [weak self] in
                        print("setting tap")
                        self?.onShowBottomSheet?(mission)
                    }
                    
                    return cell
                    
                case .add:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: AddMissionTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as? AddMissionTableViewCell else { return UITableViewCell() }
                    
                    cell.onTapAdd = { [weak self] in
                        // TODO: 미션 추천 화면 이동
                        print("Add Button 동작")
                    }
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.showTodayMissionFlow
            .emit(onNext: { [weak self] in
                self?.onSelectTodayMission?()
            })
            .disposed(by: disposeBag)
        
        output.error
            .emit(onNext: { err in
                print("Home Error Occurred: \(err)")
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HomeSectionHeaderView()
        
        return header
    }
}
