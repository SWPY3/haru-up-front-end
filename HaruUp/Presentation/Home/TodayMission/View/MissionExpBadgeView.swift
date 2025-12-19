//
//  MissionExpBadgeView.swift
//  HaruUp
//
//  Created by 조영현 on 12/18/25.
//

import UIKit

final class MissionExpBadgeView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .neutral600
        
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
        self.backgroundColor = .neutral10
    }
    
    private func configureLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    func configure(exp: Int) {
        let expString: String = "\(exp) EXP"
        self.label.setStyle(Typography.exp, text: expString)
    }
}
