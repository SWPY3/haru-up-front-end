//
//  ChartEmptyViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

class ChartEmptyViewController: UIViewController {
    
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
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        // 그림자 효과
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let graphImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "graph_chart")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "아직 충분한 데이터가 모이지 않았어요!")
        label.textColor = .neutral1000
        return label
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "많이 선택된 미션 TOP 5를 확인할 수 있는\n월간 미션 차트가 곧 업데이트돼요.")
        label.textColor = .neutral900
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
    }
    
    private func setupView() {
        view.backgroundColor = .neutral10
        
        [titleLabel, infoButton, cardView, tooltipView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [graphImageView, emptyTitleLabel, emptyDescriptionLabel].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 타이틀 레이블
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // i 버튼
            infoButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            infoButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            
            // 카드 뷰
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardView.heightAnchor.constraint(equalToConstant: 280),
            
            // 말풍선 툴팁 (i 버튼 아래에 위치)
            tooltipView.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 8),
            tooltipView.leadingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -51),
            tooltipView.widthAnchor.constraint(equalToConstant: 220),
            tooltipView.heightAnchor.constraint(equalToConstant: 45),
            
            // 카드 내부 요소들
            graphImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            graphImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            graphImageView.widthAnchor.constraint(equalToConstant: 100),
            graphImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: graphImageView.bottomAnchor, constant: 24),
            emptyTitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            emptyDescriptionLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 12),
            emptyDescriptionLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        // 화면 터치 시 툴팁 닫기 (선택 사항)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTooltip))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func infoButtonTapped() {
        tooltipView.isHidden.toggle()
    }
    
    @objc private func dismissTooltip() {
        tooltipView.isHidden = true
    }
}
