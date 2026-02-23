//
//  TodayMissionRefreshFooterView.swift
//  HaruUp
//
//  Created by 조영현 on 12/24/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TodayMissionRefreshFooterView: UIView {
    
    private let disposeBag = DisposeBag()
    
    let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        
        return stackView
    }()
    
    let refreshButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .cta
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        
        var titleContainer = AttributeContainer()
        titleContainer.font = Typography.retryButton.font
        config.attributedTitle = AttributedString("다른 추천 0/5", attributes: titleContainer)
        config.image = .iconRetry
        config.imagePadding = 4
        
        let button = UIButton(configuration: config)
        
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.configurationUpdateHandler = { button in
            switch button.state {
            case .disabled:
                button.configuration?.baseBackgroundColor = .neutral200
                
            case .highlighted:
                button.configuration?.baseBackgroundColor = .neutral600
                
            default:
                button.configuration?.baseBackgroundColor = .neutral500
            }
        }
        
        return button
    }()
    
    private let infoButton: UIButton = {
        var config = UIButton.Configuration.plain()
        
        config.image = .iconInfo
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let button = UIButton(configuration: config)
         button.configuration?.background.backgroundColor = .clear
        
        return button
    }()
    
    private let tooltipView: MissionToolTipView = {
        let view = MissionToolTipView(
            text: "매일 5회 미션을 다시 추천받을 수 있어요!",
            arrowPosition: .right)
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
        configureStackView()
        configureTooltipView()
    }
    
    private func configureStackView() {
        self.addSubview(hStackView)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [refreshButton, infoButton].forEach {
            hStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: self.topAnchor),
            hStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            infoButton.widthAnchor.constraint(equalToConstant: 36),
            infoButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func configureTooltipView() {
        self.addSubview(tooltipView)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tooltipView.bottomAnchor.constraint(equalTo: infoButton.topAnchor, constant: -4),
            tooltipView.trailingAnchor.constraint(equalTo: infoButton.centerXAnchor, constant: 16) /// trailing + width/2 = 7 + 18/2 =  16
        ])
    }
    
    private func bind() {
        infoButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                AnalyticsManager.shared.track(event: AppEvent.MissionList.infoIconTapped)
                
                self?.toggleTooltip()
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleTooltip() {
        if tooltipView.isHidden {
            tooltipView.isHidden = false
            tooltipView.transform = CGAffineTransform(translationX: 0, y: 10) // 살짝 아래에서 올라오는 효과
            
            UIView.animate(withDuration: 0.2) {
                self.tooltipView.alpha = 1
                self.tooltipView.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tooltipView.alpha = 0
                self.tooltipView.transform = CGAffineTransform(translationX: 0, y: 10)
            }) { _ in
                self.tooltipView.isHidden = true
            }
        }
    }
    
    func updateRefreshButtonCount(_ count: Int) {
        guard var config = refreshButton.configuration else { return }
        
        var titleContainer = AttributeContainer()
        titleContainer.font = Typography.retryButton.font // 기존 코드와 동일한 폰트 사용
        
        let newTitle = "다른 추천 \(count)/5"
        config.attributedTitle = AttributedString(newTitle, attributes: titleContainer)
        
        refreshButton.configuration = config
        
        // 미션 재추천 5회를 한경우 해당 버튼 비활성화
        if count == 5 {
            refreshButton.isEnabled = false
        } else {
            refreshButton.isEnabled = true
        }
    }
}
