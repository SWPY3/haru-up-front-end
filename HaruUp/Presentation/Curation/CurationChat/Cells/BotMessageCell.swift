//
//  BotMessageCell.swift
//  HaruUp
//
//  Created by 조영현 on 4/6/26.
//

import UIKit

// MARK: - Bot Message Cell
final class BotMessageCell: UITableViewCell {
    static let identifier = "BotMessageCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.neutral50.cgColor
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let shimmerTextView: ShimmerTextLabel = {
        let view = ShimmerTextLabel()
        view.isHidden = true
        return view
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .neutral400
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(shimmerTextView)
        contentView.addSubview(subtitleLabel)

        bubbleView.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            paddingTop: 8,
            paddingLeft: 16
        )
        bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8
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
        
        shimmerTextView.anchor(
            top: bubbleView.topAnchor,
            left: bubbleView.leftAnchor,
            bottom: bubbleView.bottomAnchor,
            right: bubbleView.rightAnchor,
            paddingTop: 12,
            paddingLeft: 14,
            paddingBottom: 12,
            paddingRight: 14
        )
        
        subtitleLabel.anchor(
            top: bubbleView.bottomAnchor,
            left: bubbleView.leftAnchor,
            bottom: contentView.bottomAnchor,
            paddingTop: 4,
            paddingLeft: 4,
            paddingBottom: 4
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subtitleLabel.isHidden = true
        messageLabel.attributedText = nil
        
        messageLabel.isHidden = false
        shimmerTextView.isHidden = true
        shimmerTextView.stopShimmering()
    }

    func configure(text: String, highlightedText: String? = nil, subtitleText: String? = nil, isShimmering: Bool = false) {
        if isShimmering {
            // bubbleView 높이 확보를 위해 messageLabel에도 텍스트 설정 (표시는 숨김)
            messageLabel.setStyle(Typography.body4, text: text)
            messageLabel.isHidden = true
            shimmerTextView.isHidden = false

            shimmerTextView.text = text
            shimmerTextView.font = Typography.body4.font

            shimmerTextView.startShimmering()
        } else {
            messageLabel.isHidden = false
            shimmerTextView.isHidden = true
            shimmerTextView.stopShimmering()
            
            if let highlighted = highlightedText {
                messageLabel.setStyledText(
                    Typography.body4,
                    fullText: text,
                    highlightedText: highlighted,
                    highlightedColor: .black,
                    defaultColor: .neutral800,
                    highlightedFont: Typography.body2.font
                )
            } else {
                messageLabel.setStyle(Typography.body4, text: text)
                messageLabel.textColor = .black
            }
        }

        if let subtitle = subtitleText {
            subtitleLabel.setStyle(Typography.caption3, text: subtitle)
            subtitleLabel.textColor = .neutral400
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}
