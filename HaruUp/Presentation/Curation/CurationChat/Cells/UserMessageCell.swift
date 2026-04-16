//
//  UserMessageCell.swift
//  HaruUp
//
//  Created by 조영현 on 4/6/26.
//

import UIKit

// MARK: - User Message Cell
final class UserMessageCell: UITableViewCell {
    static let identifier = "UserMessageCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .neutral900
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        bubbleView.anchor(
            top: contentView.topAnchor,
            right: contentView.rightAnchor,
            paddingTop: 8,
            paddingRight: 16
        )
        bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7
        ).isActive = true

        messageLabel.anchor(
            top: bubbleView.topAnchor,
            left: bubbleView.leftAnchor,
            bottom: bubbleView.bottomAnchor,
            right: bubbleView.rightAnchor,
            paddingTop: 12,
            paddingLeft: 14,
            paddingBottom: 12,
            paddingRight: 14
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, onEdit: (() -> Void)?) {
        messageLabel.setStyle(Typography.body4, text: text)
        messageLabel.textColor = .white
    }
}
