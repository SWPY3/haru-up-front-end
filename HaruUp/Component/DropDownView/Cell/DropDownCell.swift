//
//  DropDownCell.swift
//  HaruUp
//
//  Created by 하다현 on 1/1/26.
//

import UIKit

final class DropdownCell: UITableViewCell {
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(text: String, isSelected: Bool) {
        label.text = text
        if isSelected {
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            label.textColor = .systemBlue
            label.font = UIFont.boldSystemFont(ofSize: 15)
        } else {
            contentView.backgroundColor = .white
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 15)
        }
    }
}
