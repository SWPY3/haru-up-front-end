//
//  TodayMissionSectionHeaderView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TodayMissionSectionHeaderView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "오늘의 AI 추천미션")
        label.textColor = .black
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "미션은 하루 최대 5개까지 선택할 수 있어요.")
        label.textColor = .neutral500
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .neutral10
        
        configureLabel()
    }
    
    private func configureLabel() {
        [titleLabel, subtitleLabel].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
}
