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
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 AI 추천 미션"
        label.textAlignment = .center
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "하루 최대 5개까지 선택할 수 있어요."
        label.textAlignment = .center
        
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(TodayMissionTableViewCell.self, forCellReuseIdentifier: TodayMissionTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        
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
        view.backgroundColor = .lightGray
        
        configureActivityIndicator()
        configureTitle()
        configureCompleteButton()
        configureTableview()
    }
    
    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureTitle() {
        view.addSubview(titleStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, descriptionLabel].forEach { label in
            titleStackView.addArrangedSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 20),
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
        
        let missions = output.missions
            .observe(on: MainScheduler.instance)
            .share(replay: 1) // 같은 스트림을 여러 곳에서 쓰기 위한 공유

        missions
            .bind(to: tableView.rx.items(
                cellIdentifier: TodayMissionTableViewCell.identifier,
                cellType: TodayMissionTableViewCell.self
            )) { row, mission, cell in
                cell.configure(title: mission.content)
            }
            .disposed(by: disposeBag)

        missions
            .subscribe(onNext: { missions in
                print("recommend Mission API")
                print("받은 미션 개수: \(missions.count)")

                missions.forEach { mission in
                    print("----")
                    print("seqNo: \(mission.seqNo)")
                    print("content: \(mission.content)")
                    print("relatedInterest: \(mission.relatedInterest)")
                    print("difficulty: \(mission.difficulty)")
                }
            }, onError: { error in
                print("추천 미션 API 에러: \(error)")
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                // TODO: reset Button등 다른 버튼 동작 제한
                if isLoading {
                    print("로딩 시작")
                    self?.activityIndicator.startAnimating()
                } else {
                    print("로딩 종료")
                    self?.activityIndicator.stopAnimating()
                }
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
