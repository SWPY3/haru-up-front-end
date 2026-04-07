//
//  ChipCollectionCell.swift
//  HaruUp
//
//  Created by 조영현 on 4/6/26.
//

import UIKit

// MARK: - Chip Collection Cell
final class ChipCollectionCell: UICollectionViewCell {
    static let identifier = "ChipCollectionCell"

    private let chipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral800
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .neutral50
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.neutral200.cgColor
        contentView.clipsToBounds = true

        contentView.addSubview(chipLabel)
        chipLabel.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor,
            right: contentView.rightAnchor,
            paddingTop: 8,
            paddingLeft: 14,
            paddingBottom: 8,
            paddingRight: 14
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        chipLabel.setStyle(Typography.body5, text: text)
        chipLabel.textColor = .neutral800
    }
}
