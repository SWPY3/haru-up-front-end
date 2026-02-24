//
//  EmptyMissionCell.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class EmptyMissionCell: UITableViewCell {
    static let identifier: String = "EmptyMissionCell"
    
    var onTapAdd: (() -> Void)?
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "오늘의 미션을 아직 선택하지 않았어요.")
        label.textColor = .neutral500
        label.textAlignment = .center
        
        return label
    }()
    
    private let addButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .cta
        config.baseForegroundColor = .white
        
        var titleContainer = AttributeContainer()
        titleContainer.font = Typography.body2.font
        config.attributedTitle = AttributedString("미션 추가하기", attributes: titleContainer)
        config.image = .iconPlus
        config.imagePadding = 6
        
        let button = UIButton(configuration: config)
        
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .neutral10
        
        configureCard()
        configureStackView()
    }
    
    private func configureCard() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureStackView() {
        cardView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [messageLabel, addButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -26),
            
            addButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    @objc private func didTapAddButton() {
        AnalyticsManager.shared.track(event: AppEvent.Home.addMissionTapped)
        onTapAdd?()
    }
}
