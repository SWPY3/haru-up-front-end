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

    /// 현재 선택된 난이도 필터
    let selectedFilterRelay = BehaviorRelay<MissionDifficultyFilter>(value: .all)

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

    private let filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private var filterButtons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .neutral10

        [titleLabel, subtitleLabel, refreshButton, filterStackView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        configureFilterButtons()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: refreshButton.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            filterStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            filterStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            filterStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            filterStackView.heightAnchor.constraint(equalToConstant: 36),
            filterStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            refreshButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    private func configureFilterButtons() {
        MissionDifficultyFilter.allCases.forEach { filter in
            let button = makeFilterButton()
            filterButtons.append(button)
            filterStackView.addArrangedSubview(button)

            button.rx.tap
                .map { filter }
                .bind(to: selectedFilterRelay)
                .disposed(by: disposeBag)
        }

        selectedFilterRelay
            .subscribe(onNext: { [weak self] filter in
                self?.updateFilterButtons(selected: filter)
            })
            .disposed(by: disposeBag)
    }

    private func makeFilterButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.background.cornerRadius = 18

        return UIButton(configuration: config)
    }

    private func updateFilterButtons(selected: MissionDifficultyFilter) {
        zip(filterButtons, MissionDifficultyFilter.allCases).forEach { button, filter in
            let isSelected = filter == selected

            guard var config = button.configuration else { return }

            var titleContainer = AttributeContainer()
            titleContainer.font = UIFont.pretendard(size: 14, weight: .semiBold)
            titleContainer.foregroundColor = isSelected ? UIColor.white : UIColor.neutral700

            config.attributedTitle = AttributedString(filter.title, attributes: titleContainer)
            config.background.backgroundColor = isSelected ? .black : .white
            button.configuration = config
        }
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
