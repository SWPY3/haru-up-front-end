//
//  MissionTableViewCell.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class MissionTableViewCell: UITableViewCell {
    static let identifier: String = "MissionTableViewCell"
    
    public var onTapSetting: (() -> Void)?
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        return view
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.iconMissionInfo, for: .normal)
        
        return button
    }()
    
    private let missionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let missionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        
        return label
    }()
    
    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7
        
        return stackView
    }()
    
    private let difficultyBadge = MissionDifficultyBadgeView()
    private let expBadge = MissionExpBadgeView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onTapSetting = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .neutral10
        
        configureCard()
        configureStackView()
        configureMission()
    }
    
    private func configureCard() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16), /// cell간 간격
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureStackView() {
        [missionStackView, settingButton].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            settingButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            settingButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            settingButton.widthAnchor.constraint(equalToConstant: 24),
            settingButton.heightAnchor.constraint(equalToConstant: 24),
            
            missionStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            missionStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            missionStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            missionStackView.trailingAnchor.constraint(equalTo: settingButton.leadingAnchor, constant: -40)
        ])
    }
    
    private func configureMission() {
        [missionLabel, badgeStackView].forEach {
            missionStackView.addArrangedSubview($0)
        }
        
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.backgroundColor = .clear
        
        [difficultyBadge, expBadge, spacerView].forEach {
            badgeStackView.addArrangedSubview($0)
        }
    }
    
    private func setButton() {
        settingButton.addTarget(self, action: #selector(settingButtonTap), for: .touchUpInside)
    }
    
    @objc private func settingButtonTap() {
        onTapSetting?()
    }
    
    func configure(mission: Mission) {
        missionLabel.setStyle(Typography.subtitle2, text: mission.title)
        difficultyBadge.configure(difficulty: mission.difficulty)
        expBadge.configure(exp: mission.exp)
    }
}
