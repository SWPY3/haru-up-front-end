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
    
    private let selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = .calendarSelected
        view.clipsToBounds = true
        view.isHidden = true  // 기본값은 숨김
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀 재사용 시 초기화
        selectedView.isHidden = true
        todayImageView.alpha = 0.0
        clearMissionImageView.alpha = 0.0
        dayLabel.text = ""
        dayLabel.textColor = .black
    }
    
    private func setupUI() {
        contentView.addSubview(todayImageView)
        contentView.addSubview(clearMissionImageView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(selectedView)
        
        NSLayoutConstraint.activate([
            todayImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            todayImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            clearMissionImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clearMissionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedView.widthAnchor.constraint(equalTo: clearMissionImageView.widthAnchor),
            selectedView.heightAnchor.constraint(equalTo: clearMissionImageView.widthAnchor),
        ])
    }
    
    func configure(day: Int, isCurrentMonth: Bool, isSelected: Bool, isToday: Bool, missionCount: Int) {
        
        dayLabel.text = "\(day)"
        
        // 현재 월이 아닌 경우 (이전달/다음달)
        if !isCurrentMonth {
            dayLabel.textColor = .neutral200  // 회색으로 표시
            todayImageView.alpha = 0.0
            clearMissionImageView.alpha = 0.0
            selectedView.isHidden = true
            return
        }
        
        // 선택 상태 처리
        selectedView.isHidden = !isSelected
        selectedView.layer.cornerRadius = selectedView.bounds.width / 2
        
        // 오늘 날짜 표시
        todayImageView.alpha = isToday ? 1.0 : 0.0
        
        // 미션 완료 표시 및 텍스트 색상
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
