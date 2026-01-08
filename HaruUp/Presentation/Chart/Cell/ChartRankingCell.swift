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
    }
    
    
    func setRoundedCorners(isFirst: Bool, isLast: Bool) {
        let cornerRadius: CGFloat = 16.0 // 원하는 둥글기 정도 (UI에 맞춰 조절)
        
        // 1. 기본적으로 둥글게 처리할 준비
        self.layer.cornerRadius = cornerRadius
//        self.layer.masksToBounds = true // 내용이 모서리를 넘어가면 자름
        
        // 2. 위치에 따라 마스킹할 모서리 결정
        if isFirst && isLast {
            // 데이터가 1개뿐일 때: 4면 모두 둥글게
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            // 첫 번째 셀: 위쪽 두 모서리만
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            // 마지막 셀: 아래쪽 두 모서리만
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // 중간 셀: 둥글기 없음 (재사용 시 꼭 초기화 필요!)
            self.layer.cornerRadius = 0
            self.layer.maskedCorners = []
        }
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        selectionStyle = .none
        
        [fireIconImageView, countLabel].forEach { countStackView.addArrangedSubview($0) }
        [rankLabel, titleLabel, tagStackView, countStackView].forEach {
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
            titleLabel.topAnchor.constraint(equalTo: rankLabel.topAnchor),
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
            
            fireIconImageView.widthAnchor.constraint(equalToConstant: 14),
            fireIconImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    // MARK: - Configure
    func configure(with item: ChartItem) {
        rankLabel.text = "\(item.rank)"
        titleLabel.text = item.title
        countLabel.text = "\(item.count)명이 선택했어요"
        
        // 태그 동적 생성
        item.tags.forEach { tagText in
            let container = UIView()
            container.backgroundColor = .neutral10
            container.layer.cornerRadius = 12
            
            let label = UILabel()
            label.text = tagText
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
