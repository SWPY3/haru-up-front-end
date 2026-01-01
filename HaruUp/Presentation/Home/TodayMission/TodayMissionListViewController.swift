//
//  TodayMissionListViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class TodayMissionListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: TodayMissionListViewModel
    
    var onComplete: (() -> Void)?
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let refreshTapSubject = PublishSubject<Void>()
    
    /// Cell 구성시 선택한 ID인지를 파악하기 위한 변수
    private var currentSelectedIDs: Set<Int> = []
    
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconXmark, for: .normal)
        
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .neutral10
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.sectionHeaderTopPadding = 0
        tableView.allowsMultipleSelection = true
        
        tableView.register(SkeletonMissionCell.self, forCellReuseIdentifier: SkeletonMissionCell.identifier)
        tableView.register(TodayMissionTableViewCell.self, forCellReuseIdentifier: TodayMissionTableViewCell.identifier)
        
        return tableView
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setTitle("refresh", for: .normal)
        button.backgroundColor = .yellow
        
        return button
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("complete", for: .normal)
        button.backgroundColor = .green
        
        return button
    }()
    
    private let bottomViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let loadingButtonView: LoadingButtonView = {
        let view = LoadingButtonView()
        
        return view
    }()
    
    private let selectedButtonView: TodayMissionSelectView = {
        let view = TodayMissionSelectView()
        view.isHidden = true
        
        return view
    }()
    
    private let refreshFooterView: TodayMissionRefreshFooterView = {
        let view = TodayMissionRefreshFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 84))
        
        return view
    }()
    
    init(viewModel: TodayMissionListViewModel) {
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
        
        viewDidLoadSubject.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        configureCloseButton()
        configureBottomView()
        configureTableview()
    }
    
    private func configureCloseButton() {
        view.addSubview(topContainerView)
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        topContainerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            closeButton.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 5),
            closeButton.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -5),
            closeButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureCompleteButton() {
        view.addSubview(refreshButton)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            refreshButton.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -30),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureTableview() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomViewContainer.topAnchor),
        ])
    }
    
    private func configureBottomView() {
        view.addSubview(bottomViewContainer)
        bottomViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        bottomViewContainer.addSubview(bottomStackView)
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [loadingButtonView, selectedButtonView].forEach {
            bottomStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            bottomViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bottomStackView.topAnchor.constraint(equalTo: bottomViewContainer.topAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomViewContainer.safeAreaLayoutGuide.bottomAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: bottomViewContainer.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomViewContainer.trailingAnchor),
            loadingButtonView.heightAnchor.constraint(equalToConstant: 75),
            selectedButtonView.heightAnchor.constraint(equalToConstant: 86),
        ])
    }
    
    private func bind() {
        let selected = tableView.rx.modelSelected(RecommendMissionRow.self).asObservable()
        let deselected = tableView.rx.modelDeselected(RecommendMissionRow.self).asObservable()
        
        let missionSelected = Observable.merge(selected, deselected)
            .compactMap { row -> Int? in
                if case .mission(let dto) = row {
                    return dto.memberMissionId
                }
                return nil
            }
        
        let input = TodayMissionListViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            refreshTap: refreshButton.rx.tap.asObservable(),
            completeTap: selectedButtonView.button.rx.tap.asObservable(),
            missionSelected: missionSelected,
            retryRecommend: refreshFooterView.refreshButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        let loadingItems = output.isLoading
            .filter { $0 } // 로딩이 시작될 때만 통과
            .withLatestFrom(Observable.combineLatest(output.missions, output.selectedIDs))
            .map { missions, selectedIDs -> [RecommendMissionRow] in
                let keptMissions = missions
                    .filter { selectedIDs.contains($0.memberMissionId) }
                    .sorted { $0.difficulty > $1.difficulty }
                let keptRows = keptMissions.map { RecommendMissionRow.mission($0) }
                
                let needCount = max(0, 5 - keptRows.count)
                let skeletonRows = Array(repeating: RecommendMissionRow.skeleton, count: needCount)
                
                return keptRows + skeletonRows
            }
        
        let missionItems = output.missions
            .map { missions -> [RecommendMissionRow] in
                let sortedMissions = missions.sorted { $0.difficulty > $1.difficulty }
                
                return sortedMissions.map { .mission($0) }
            }
        
        Observable.merge(loadingItems, missionItems)
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items) { (tableView: UITableView, row: Int, item: RecommendMissionRow) in
                let indexPath = IndexPath(row: row, section: 0)
                
                switch item {
                case .skeleton:
                    let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonMissionCell.identifier, for: indexPath) as! SkeletonMissionCell
                    
                    cell.configure(index: row)
                    
                    return cell
                    
                case .mission(let mission):
                    let cell = tableView.dequeueReusableCell(withIdentifier: TodayMissionTableViewCell.identifier, for: indexPath) as! TodayMissionTableViewCell
                    
                    guard let difficulty = MissionDifficultyModel(rawValue: mission.difficulty) else {
                        // TODO: 파악할 수 없는 난이도 error 대응 필요
                        print("파악할 수 없는 난이도")
                        return UITableViewCell()
                    }
                    
                    let isSelected = self.currentSelectedIDs.contains(mission.memberMissionId)
                    let data = Mission(id:mission.memberMissionId, title: mission.content, difficulty: difficulty, exp: mission.expEarned, isCompleted: isSelected) // isCompleted를 미션을 선택한 상태여부로 사용. 해당페이지는 미션을 추천하는 페이지이기 때문에 영향이 없다.
                    print("data: \(data)")
                    
                    cell.configure(mission: data)
                    
                    if isSelected {
                        // 애니메이션 없이, 스크롤 이동 없이 선택 상태로 만듦
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        // 재사용 셀 문제 방지를 위해 명시적 해제
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.retryCount
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
                self?.refreshFooterView.updateRefreshButtonCount(count)
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.bottomViewContainer.backgroundColor = isLoading ? .clear : .white
                self?.loadingButtonView.isHidden = !isLoading
                self?.selectedButtonView.isHidden = isLoading
                
                self?.refreshButton.isEnabled = !isLoading
                self?.completeButton.isEnabled = !isLoading
                
                self?.tableView.tableFooterView = isLoading ? nil : self?.refreshFooterView
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                print("미션 추천 에러: \(message)")
            })
            .disposed(by: disposeBag)
        
        output.missionCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.onComplete?()
            })
            .disposed(by: disposeBag)
        
        output.selectedIDs
            .subscribe(onNext: { [weak self] ids in
                self?.currentSelectedIDs = ids
            })
            .disposed(by: disposeBag)
        
        output.selectedMissionCount
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
                self?.selectedButtonView.updateSelectionCount(count)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func closeButtonTapped() {
        onComplete?()
    }
}

extension TodayMissionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TodayMissionSectionHeaderView()
        
        return header
    }
}
