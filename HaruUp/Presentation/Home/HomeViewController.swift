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
    private let reloadSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    var onSelectTodayMission: (() -> Void)? // Coordinator와의 연결은 단순히 클로저 사용
    var onShowBottomSheet: ((Mission) -> Void)?
    var onShowChallengeBottomSheet: ((Int, [DailyMissionData]) -> Void)?
    var onShowAddMission: (([Int]) -> Void)?
    
    private var challengeCount: Int = 0
    private var challengeData: [DailyMissionData] = []
    
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
    
    private weak var sectionHeaderView: HomeSectionHeaderView?
    
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
        setActions()
        
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
        sectionHeaderView?.hideTooltip()
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
        
        headerView.onTapChallenge = { [weak self] in
            guard let self = self else { return }
            
            self.onShowChallengeBottomSheet?(self.challengeCount, self.challengeData)
        }
        
        tableView.tableHeaderView = headerView
        tableView.sectionHeaderTopPadding = 28 // Section Header와 TableView Header의 간격
        
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        updateTableHeaderHeight()
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
            reload: reloadSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.userInfo
            .drive(onNext: { [weak self] info in
                guard let self = self else { return }
                
                if let headerView = self.tableView.tableHeaderView as? HomeHeaderView {
                    
                    headerView.configureUserData(userInfo: info)
                }
            })
            .disposed(by: disposeBag)
        
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
                        self?.onShowAddMission?([])
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
                        // 1. 현재 선택된 미션 ID 목록 가져오기
                        let currentIDs = self?.viewModel.currentMissionIDs
                        
                        // 2. 외부(Coordinator)로 네비게이션 요청
                        print("미션 추천 화면 이동 요청: 이미 선택된 ID \(currentIDs)")
                        self?.onShowAddMission?(currentIDs ?? [])
                    }
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(TodayMissionRow.self)
            .subscribe(onNext: { [weak self] rowType in
                guard let self = self else { return }
                
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                
                switch rowType {
                case .mission(let mission):
                    if !mission.isCompleted {
                        self.onShowBottomSheet?(mission)
                    }
                    
                case .empty, .add:
                    break
                }
            })
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
        
        output.challengeDay
            .drive(onNext: { [weak self] count in
                self?.challengeCount = count
                self?.headerView.updateChallengeDay(count)
            })
            .disposed(by: disposeBag)

        // 챌린지 버튼 눌렀을 때 보여줄 데이터 소스 갱신
        output.challengeList
            .drive(onNext: { [weak self] listData in
                self?.challengeData = listData
            })
            .disposed(by: disposeBag)
    }
    
    // Mission 선택 후 Coordinator에서 호출, 미션 완료 및 삭제 일때도 가능하게 구현
    func didCompleteMissionSelection() {
        reloadSubject.onNext(())
    }
    
    private func setActions() {
        bindGlobalActions()
    }
    
    private func bindGlobalActions() {
        // 테이블뷰 스크롤 시작 시 툴팁 닫기
        tableView.rx.willBeginDragging
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.sectionHeaderView?.hideTooltip()
            })
            .disposed(by: disposeBag)
        
        // 셀(Cell)을 탭했을 때 닫기
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] _ in
                self?.sectionHeaderView?.hideTooltip()
            })
            .disposed(by: disposeBag)
        
        // 화면 배경(빈 공간)을 터치했을 때 닫기
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false // 테이블뷰 셀 선택 이벤트를 막지 않도록 설정
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                self?.sectionHeaderView?.hideTooltip()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HomeSectionHeaderView()
        self.sectionHeaderView = header // 참조 저장
        
        return header
    }
}
