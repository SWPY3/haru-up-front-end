//
//  CalendarHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 1/14/26.
//

import UIKit

class CalendarHeaderView: UICollectionReusableView {
    static let identifier = "CalendarHeaderView"
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
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
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        weekdays.forEach { day in
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = Typography.calendarWeek.font
            label.textColor = .neutral700
            
            stackView.addArrangedSubview(label)
        }
    }
}
