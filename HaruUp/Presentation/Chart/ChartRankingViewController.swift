//
//  ChartRankingViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/7/26.
//

import UIKit

class ChartRankingViewController: UIViewController {
    
    private let viewModel: ChartViewModel
    
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
    
    // 검색 조건 추가 버튼 (상단 둥근 버튼)
    private let filterButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .iconFilter
        
        
        // attributed title 설정
        var container = AttributeContainer()
        container.font = Typography.body4.font
        config.attributedTitle = AttributedString("검색조건을 추가해보세요.", attributes: container)
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(ChartRankingCell.self, forCellReuseIdentifier: ChartRankingCell.identifier)
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.backgroundColor = .clear
        tv.delegate = self
        tv.dataSource = self
        tv.showsVerticalScrollIndicator = false
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
        
    }
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        [titleLabel, infoButton, filterButton, tableView, tooltipView, ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
            filterButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            // 말풍선 툴팁 (i 버튼 아래에 위치)
            tooltipView.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 8),
            tooltipView.leadingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -51),
            tooltipView.widthAnchor.constraint(equalToConstant: 220),
            tooltipView.heightAnchor.constraint(equalToConstant: 45),
            
            // 테이블 뷰
            tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -46)
        ])
    }
}

// MARK: - UITableView Delegate & DataSource
extension ChartRankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rankingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartRankingCell.identifier, for: indexPath) as? ChartRankingCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.rankingData[indexPath.row]
        cell.configure(with: item)
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.rankingData.count - 1
        cell.setRoundedCorners(isFirst: isFirst, isLast: isLast)
        if isLast {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // 기존에 설정한 값
        }
        return cell
    }
}
