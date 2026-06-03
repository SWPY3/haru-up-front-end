//
//  TodayMissionTableViewCell.swift
//  HaruUp
//
//  Created by 조영현 on 12/15/25.
//

import UIKit

final class TodayMissionTableViewCell: UITableViewCell {
    static let identifier: String = "TodayMissionTableViewCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.neutral50.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let missionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonCheckboxUnselected, for: .normal)
        button.setImage(.buttonCheckboxSelected, for: .selected)
        
        button.isUserInteractionEnabled = false
        
        return button
    }()
    
    private let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let missionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0

        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral700
        label.numberOfLines = 0
        label.isHidden = true

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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        applySelection(selected, animated: animated)
    }
    
    private func setupView() {
        selectionStyle = .none
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        configureCard()
        configureButton()
        configureStackView()
        configureBadgeStackView()
    }
    
    private func configureCard() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12), /// cell간 간격
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureButton() {
        cardView.addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            checkButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            checkButton.heightAnchor.constraint(equalToConstant: 24),
            checkButton.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    private func configureStackView() {
        cardView.addSubview(hStackView)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [missionLabel, descriptionLabel, badgeStackView].forEach {
            hStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            hStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30),
            hStackView.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 10),
            hStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureBadgeStackView() {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.backgroundColor = .clear
        
        [difficultyBadge, expBadge, spacerView].forEach {
            badgeStackView.addArrangedSubview($0)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.isHidden = true
        descriptionLabel.text = nil
    }

    func configure(mission: Mission) {
        missionLabel.setStyle(Typography.subtitle2, text: mission.title)
        difficultyBadge.configure(difficulty: mission.difficulty)
        expBadge.configure(exp: mission.exp)

        if let desc = mission.description, !desc.isEmpty {
            descriptionLabel.setStyle(Typography.body4, text: desc)
            descriptionLabel.textColor = .neutral700
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
    
    func updateSelectionState(isSelected: Bool, isDisabled: Bool) {
        applySelection(isSelected, animated: false)
        
        if isSelected {
            // [선택됨]
            missionLabel.textColor = .black
            self.contentView.alpha = 1.0
            self.isUserInteractionEnabled = true
            
        } else if isDisabled {
            // [비활성화] - 5개 꽉 참 & 선택 안됨
            missionLabel.textColor = .neutral700
            self.contentView.alpha = 0.7
            self.isUserInteractionEnabled = false // 터치 막기
            
        } else {
            // [기본] - 선택 가능
            missionLabel.textColor = .black
            self.contentView.alpha = 1.0
            self.isUserInteractionEnabled = true
        }
    }
    
    private func applySelection(_ selected: Bool, animated: Bool) {
        let changes = {
            self.cardView.layer.borderWidth = selected ? 1.5 : 1.0
            self.cardView.layer.borderColor = selected ? UIColor.primaryBlue500.cgColor : UIColor.neutral50.cgColor
            self.checkButton.isSelected = selected
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: changes)
        } else {
            changes()
        }
    }
}
