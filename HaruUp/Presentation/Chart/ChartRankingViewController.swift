//
//  ChartRankingViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/7/26.
//

import UIKit
import RxSwift
import RxCocoa

class ChartRankingViewController: UIViewController, FilterModalDelegate {
    
    private let viewModel: ChartViewModel
    private var currentActiveTags: [String] = []
    private let disposeBag = DisposeBag()
    
    private var rankingData: [ChartItem] = []
    
    private let filterAppliedSubject = PublishSubject<[String]>()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "월간 미션 차트 TOP5")
        label.textColor = .black
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(.iconInfo, for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    // i 버튼 클릭 시 나타날 말풍선
    private let tooltipView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .icardChart
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // 검색 조건 버튼
    private let filterButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconFilter, for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconReset, for: .normal)
        button.contentMode = .scaleAspectFit
        button.isHidden = true // 초기엔 숨김
        return button
    }()
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "검색조건을 추가해보세요."
        label.font = Typography.body4.font
        label.textColor = .neutral500
        return label
    }()
    
    private let filterScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.isHidden = true
        return sv
    }()
    
    private let filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(ChartRankingCell.self, forCellReuseIdentifier: ChartRankingCell.identifier)
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.showsVerticalScrollIndicator = false
        tv.layer.cornerRadius = 20
        tv.clipsToBounds = true
        return tv
    }()
    
    // MARK: - Init
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
        bindViewModel()
    }
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        [titleLabel, infoButton, filterButton, resetButton, filterLabel, filterScrollView, tableView, tooltipView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        filterScrollView.addSubview(filterStackView)
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 타이틀
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // i 버튼
            infoButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            infoButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            
            // 필터 버튼
            filterButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            filterButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            // 초기화 버튼
            resetButton.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor),
            resetButton.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor, constant: 8),
            resetButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 필터 안내 텍스트
            filterLabel.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor),
            filterLabel.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor, constant: 8),
            
            // 가로 스크롤 뷰
            filterScrollView.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor),
            filterScrollView.leadingAnchor.constraint(equalTo: resetButton.trailingAnchor, constant: 4),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterScrollView.heightAnchor.constraint(equalToConstant: 35),
            
            // 스크롤뷰 내부 스택뷰
            filterStackView.topAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.trailingAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.bottomAnchor),
            filterStackView.heightAnchor.constraint(equalTo: filterScrollView.frameLayoutGuide.heightAnchor),
            
            // 말풍선 툴팁 (i 버튼 아래에 위치)
            tooltipView.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 8),
            tooltipView.leadingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -51),
            tooltipView.widthAnchor.constraint(equalToConstant: 220),
            tooltipView.heightAnchor.constraint(equalToConstant: 45),
            
            // 테이블 뷰
            tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -46)
        ])
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        let input = ChartViewModel.Input(
            viewDidLoad: Observable.just(()),
            filterApplied: filterAppliedSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 랭킹 데이터 변화 감지하여 테이블뷰 리로드
        output.rankingData
            .drive(onNext: { [weak self] data in
                self?.rankingData = data
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupActions() {
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        // 화면 터치 시 툴팁 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTooltip))
        view.addGestureRecognizer(tapGesture)
    }
    
    func didApplyFilter(selectedTags: [String]) {
        self.currentActiveTags = selectedTags
        print("사용자가 필터 적용 버튼 클릭함: \(selectedTags)")
        
        // 1. 기존 태그들 모두 제거
        filterStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if selectedTags.isEmpty {
            // 태그가 없으면 -> 초기 상태로 복구
            resetUIState(isActive: false)
        } else {
            // 태그가 있으면 -> 태그 뷰 생성 및 UI 활성화
            resetUIState(isActive: true)
            
            for tagText in selectedTags {
                let tagView = createSelectedTagView(text: tagText)
                filterStackView.addArrangedSubview(tagView)
            }
        }
        filterAppliedSubject.onNext(selectedTags)
    }
    
    // UI 상태 전환 (초기 상태 <-> 필터 적용 상태)
    private func resetUIState(isActive: Bool) {
        filterLabel.isHidden = isActive
        resetButton.isHidden = !isActive
        filterScrollView.isHidden = !isActive
        
        // 필터 버튼 아이콘 색상 변경 (활성 시 파랑, 비활성 시 검정/기본)
        if isActive {
            filterButton.setImage(.iconFilterSelected, for: .normal)
        } else {
            // 기본 상태
            filterButton.setImage(.iconFilter, for: .normal)
        }
    }
    
    // 태그 뷰 생성 (캡슐 모양 + 닫기 X 버튼 포함)
    private func createSelectedTagView(text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.neutral50.cgColor
        
        let label = UILabel()
        label.text = text
        label.font = Typography.body4.font
        label.textColor = .neutral800
        
        let deleteButton = UIButton()
        deleteButton.setImage(.iconCancel, for: .normal)
        deleteButton.contentMode = .scaleAspectFit
        
        deleteButton.addTarget(self, action: #selector(removeTag(_:)), for: .touchUpInside)
        
        [label, deleteButton].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 32),
            
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            deleteButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 2),
            deleteButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            deleteButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
        ])
        
        return container
    }
    
    @objc private func removeTag(_ sender: UIButton) {
        // 1. 스택뷰에서 해당 버튼 제거
        guard let tagContainer = sender.superview else { return }
        
        if let label = tagContainer.subviews.first(where: { $0 is UILabel }) as? UILabel,
           let textToRemove = label.text {
            // 배열에서 해당 텍스트 제거
            currentActiveTags.removeAll { $0 == textToRemove }
        }
        
        tagContainer.removeFromSuperview()
        filterStackView.layoutIfNeeded()
        
        // 2. 남은 태그가 있는지 확인
        if filterStackView.arrangedSubviews.isEmpty {
            // 태그가 하나도 없으면 초기 상태(라벨 표시)로 돌아감
            resetUIState(isActive: false)
        }
        print("태그 삭제됨. 남은 태그로 재검색: \(currentActiveTags)")
        filterAppliedSubject.onNext(currentActiveTags)
    }
    
    @objc private func infoButtonTapped() {
        tooltipView.isHidden.toggle()
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterModalViewController()
        filterVC.modalPresentationStyle = .pageSheet
        filterVC.delegate = self
        
        filterVC.initialSelectedTags = self.currentActiveTags
        
        // 모달 스타일 설정
//        if let sheet = filterVC.sheetPresentationController {
//            // .medium()은 화면 절반, .large()는 전체 화면
//            sheet.detents = [.medium(), .large()]
//            // 상단 핸들러(잡고 끄는 바) 표시
//            sheet.prefersGrabberVisible = true
//            sheet.preferredCornerRadius = 20
//            
//            sheet.prefersEdgeAttachedInCompactHeight = true
//            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//        }
        
        present(filterVC, animated: true)
    }
    
    @objc private func resetButtonTapped() {
        // 초기화 버튼 누르면 모든 필터 해제
        self.currentActiveTags = []
        didApplyFilter(selectedTags: [])
    }
    
    @objc private func dismissTooltip() {
        tooltipView.isHidden = true
    }
}

// MARK: - UITableView Delegate & DataSource
extension ChartRankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartRankingCell.identifier, for: indexPath) as? ChartRankingCell else {
            return UITableViewCell()
        }
        
        let item = rankingData[indexPath.row]
        cell.configure(with: item)
        
        if indexPath.row == rankingData.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        return cell
    }
}
