//
//  CalendarCell.swift
//  HaruUp
//
//  Created by 조영현 on 1/14/26.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    static let identifier = "CalendarCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Typography.calendarDay.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let todayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconCalendarToday
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let clearMissionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconCalendarClear1
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(todayImageView)
        contentView.addSubview(clearMissionImageView)
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            todayImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            todayImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            todayImageView.widthAnchor.constraint(equalToConstant: 50),
//            todayImageView.heightAnchor.constraint(equalToConstant: 50),
            
            clearMissionImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clearMissionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(day: Int?, isSelected: Bool, isToday: Bool, hasAttendance: Bool, missionCount: Int, isSpecial: Bool) {
        guard let day = day else {
            dayLabel.text = ""
            todayImageView.alpha = 0.0
            dotsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            return
        }
        
        dayLabel.text = "\(day)"
        
        if isToday {
            todayImageView.alpha = 1.0
        } else {
            todayImageView.alpha = 0.0
        }
        
        if missionCount > 0 {
            clearMissionImageView.alpha = 1.0
            let missionCountString = "icon_calendar_clear_\(missionCount)"
            clearMissionImageView.image = UIImage(named: missionCountString)
            dayLabel.textColor = .calendarDayWhite
        } else {
            clearMissionImageView.alpha = 0.0
            dayLabel.textColor = .black
        }
    }
}
