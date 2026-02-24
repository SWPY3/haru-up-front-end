//
//  HomeSectionHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeSectionHeaderView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "오늘의 미션")
        label.textColor = .black
        
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconInfo, for: .normal)
        
        return button
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "미션은 하루 최대 5개까지 선택할 수 있어요.")
        label.textColor = .neutral500
        
        return label
    }()
    
    private let tooltipView: MissionToolTipView = {
        let view = MissionToolTipView(
            text: "오늘의 미션은 자정이 지나면 사라져요.",
            arrowPosition: .left)
        view.isHidden = true
        view.alpha = 0
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        
        configureLabel()
        configureTooltipView()
    }
    
    private func configureLabel() {
        [stackView, subtitleLabel].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, infoButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
    }
    
    private func configureTooltipView() {
        self.addSubview(tooltipView)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tooltipView.bottomAnchor.constraint(equalTo: infoButton.topAnchor, constant: -7),
            tooltipView.leadingAnchor.constraint(equalTo: infoButton.centerXAnchor, constant: -33) /// leading + width/2 = 24 + 18/2 = 33
        ])
    }
    
    private func bind() {
        infoButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                AnalyticsManager.shared.track(event: AppEvent.Home.todayMissionInfoTapped)
                self?.toggleTooltip()
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleTooltip() {
        if tooltipView.isHidden {
            showTooltip()
        } else {
            hideTooltip()
        }
    }
    
    private func showTooltip() {
        guard tooltipView.isHidden else { return }
        
        tooltipView.isHidden = false
        tooltipView.transform = CGAffineTransform(translationX: 0, y: 10)
        
        UIView.animate(withDuration: 0.2) {
            self.tooltipView.alpha = 1
            self.tooltipView.transform = .identity
        }
    }
    
    func hideTooltip() {
        // 이미 숨겨져 있다면 실행하지 않음
        guard !tooltipView.isHidden else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.tooltipView.alpha = 0
            self.tooltipView.transform = CGAffineTransform(translationX: 0, y: 10)
        }) { _ in
            self.tooltipView.isHidden = true
        }
    }
}
