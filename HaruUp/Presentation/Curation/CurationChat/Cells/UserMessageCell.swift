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

    private var onEditTapped: (() -> Void)?

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

    private let editButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("수정하기", for: .normal)
        btn.setTitleColor(.neutral400, for: .normal)
        btn.titleLabel?.font = Typography.caption2.font
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(editButton)

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

        editButton.anchor(
            top: bubbleView.bottomAnchor,
            bottom: contentView.bottomAnchor,
            right: bubbleView.rightAnchor,
            paddingTop: 2,
            paddingBottom: 4
        )

        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onEditTapped = nil
    }

    @objc private func editButtonTapped() {
        onEditTapped?()
    }

    func configure(text: String, onEdit: (() -> Void)?) {
        messageLabel.setStyle(Typography.body4, text: text)
        messageLabel.textColor = .white
        onEditTapped = onEdit
    }
}
