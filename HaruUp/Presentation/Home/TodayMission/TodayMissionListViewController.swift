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
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.bounces = false
        
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
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        configureCompleteButton()
        configureTableview()
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: refreshButton.topAnchor, constant: -20),
        ])
    }
    
    private func bind() {
        let input = TodayMissionListViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            refreshTap: refreshButton.rx.tap.asObservable(),
            completeTap: completeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        let items = Observable
            .combineLatest(
                output.isLoading.distinctUntilChanged(),
                output.missions.startWith([])
            )
            .map { isLoading, missions -> [RecommendMissionRow] in
                if isLoading {
                    return Array(repeating: .skeleton, count: 5)
                } else {
                    return missions.map { .mission($0) }
                }
            }
            .observe(on: MainScheduler.instance)
        
        items
            .bind(to: tableView.rx.items) { (tableView: UITableView, row: Int, item: RecommendMissionRow) in
                let indexPath = IndexPath(row: row, section: 0)
                
                switch item {
                case .skeleton:
                    let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonMissionCell.identifier, for: indexPath) as! SkeletonMissionCell
                    
                    cell.configure(index: row)
                    
                    return cell
                    
                case .mission(let mission):
                    let cell = tableView.dequeueReusableCell(withIdentifier: TodayMissionTableViewCell.identifier, for: indexPath) as! TodayMissionTableViewCell
                    
                    cell.configure(title: mission.content)
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.refreshButton.isEnabled = !isLoading
                self?.completeButton.isEnabled = !isLoading
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
                print("미션 선택 완료 -> 홈 화면 이동")
                self?.onComplete?()
            })
            .disposed(by: disposeBag)
    }
}

extension TodayMissionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HomeSectionHeaderView()
        
        return header
    }
}
