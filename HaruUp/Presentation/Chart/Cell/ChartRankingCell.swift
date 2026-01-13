//
//  ChartRankingCell.swift
//  HaruUp
//
//  Created by 하다현 on 1/7/26.
//

import UIKit

final class ChartRankingCell: UITableViewCell {
    static let identifier = "ChartRankingCell"
    
    // MARK: - UI Components
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.subtitle2.font
        label.textColor = .cta
        label.backgroundColor = .primaryBlue100
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "")
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    // 태그들을 담을 스택뷰
    private let tagStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private let fireIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .iconChallengeFire
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.footnote.font
        label.textColor = .primaryBlue500
        return label
    }()
    
    private let countStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 재사용 시 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        separatorView.isHidden = false
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        selectionStyle = .none
        
        [fireIconImageView, countLabel].forEach { countStackView.addArrangedSubview($0) }
        [rankLabel, titleLabel, tagStackView, countStackView, separatorView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 순위 (왼쪽 파란 박스)
            rankLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            rankLabel.widthAnchor.constraint(equalToConstant: 24),
            rankLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // 제목
            titleLabel.centerYAnchor.constraint(equalTo: rankLabel.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 태그 스택뷰
            tagStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tagStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            tagStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            tagStackView.heightAnchor.constraint(equalToConstant: 24),
            
            // 참여 인원 (불꽃 아이콘 + 텍스트)
            countStackView.topAnchor.constraint(equalTo: tagStackView.bottomAnchor, constant: 16),
            countStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            countStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            fireIconImageView.widthAnchor.constraint(equalToConstant: 16),
            fireIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            countLabel.bottomAnchor.constraint(equalTo: countStackView.bottomAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    // MARK: - Configure
    func configure(with item: ChartItem, isLastItem: Bool) {
        rankLabel.setStyle(Typography.subtitle2, text: "\(item.rank)")
        titleLabel.setStyle(Typography.subtitle2, text: item.title)
        countLabel.setStyle(Typography.footnote, text: "\(item.count)명이 선택했어요")
        
        separatorView.isHidden = isLastItem
        
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 태그 동적 생성
        item.tags.prefix(2).enumerated().forEach { index, tagText in
            var displayText = tagText
            if index == 0 {
                let icon = Interest.iconForInterest(name: tagText)
                displayText = "\(icon) \(tagText)"
            }
            
            let container = UIView()
            container.backgroundColor = .neutral10
            container.layer.cornerRadius = 12
            
            let label = UILabel()
            label.text = displayText
            label.font = Typography.body4.font
            label.textColor = .neutral700
            
            container.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
            ])
            
            tagStackView.addArrangedSubview(container)
        }
    }
}
