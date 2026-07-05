//
//  TodayMissionSectionHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TodayMissionSectionHeaderView: UIView {

    private let disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "AI 추천미션")
        label.textColor = .black
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "미션은 하루 최대 5개까지 선택할 수 있어요.")
        label.textColor = .neutral500
        return label
    }()

    let refreshButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .neutral500
        config.background.backgroundColor = .clear

        var titleContainer = AttributeContainer()
        titleContainer.font = Typography.retryButton.font
        titleContainer.foregroundColor = UIColor.neutral500
        config.attributedTitle = AttributedString("다른 추천 0/5회", attributes: titleContainer)
        config.image = .iconRetry
        config.imagePadding = 4
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .neutral10

        [titleLabel, subtitleLabel, refreshButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: refreshButton.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            refreshButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    func updateRefreshButtonCount(_ count: Int) {
        guard var config = refreshButton.configuration else { return }

        var titleContainer = AttributeContainer()
        titleContainer.font = Typography.retryButton.font
        titleContainer.foregroundColor = count < 5 ? UIColor.neutral500 : UIColor.neutral300

        config.attributedTitle = AttributedString("다른 추천 \(count)/5회", attributes: titleContainer)
        config.baseForegroundColor = count < 5 ? .neutral500 : .neutral300
        refreshButton.configuration = config
        refreshButton.isEnabled = count < 5
    }
}
