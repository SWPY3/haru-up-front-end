//
//  MissionDifficultyBadgeView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class MissionDifficultyBadgeView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
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
        configureView()
        configureLabel()
    }
    
    private func configureView() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    private func configureLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])
    }
    
    func configure(difficulty: MissionDifficultyModel) {
        self.backgroundColor = difficulty.color
        self.label.textColor = difficulty.textColor
        
        self.label.setStyle(Typography.difficulty, text: difficulty.title)
    }
}
