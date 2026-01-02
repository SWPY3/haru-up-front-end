//
//  DayItemView.swift
//  HaruUp
//
//  Created by 조영현 on 1/2/26.
//

import UIKit

final class DayItemView: UIView {
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral500
        label.textAlignment = .center
        
        return label
    }()
    
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        configureTitle()
        configureImageView()
    }
    
    private func configureTitle() {
        addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: topAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func configureImageView() {
        addSubview(statusImageView)
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statusImageView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 9),
            statusImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(data: DailyMissionData) {
        dayLabel.setStyle(Typography.body3, text: data.dayString)
        statusImageView.image = data.status.iconImage
    }
}
