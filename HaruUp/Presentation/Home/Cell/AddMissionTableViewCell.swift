//
//  AddMissionTableViewCell.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class AddMissionTableViewCell: UITableViewCell {
    static let identifier: String = "AddMissionTableViewCell"
    
    var onTapAdd: (() -> Void)?
    
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
     
        configureButton()
    }
    
    private func configureButton() {
        contentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 56)
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
