//
//  JobSelectButton.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit

class JobSelectButton: UIButton {
    
    private var isJobSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        backgroundColor = .systemGray6
        
        titleLabel?.font = .systemFont(ofSize: 16)
        setTitleColor(.black, for: .normal)
        
        
        var configuration = Configuration.plain()
        configuration.titleAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 0)
        self.configuration = configuration
    }
    
    func setSelected(_ selected: Bool) {
        isJobSelected = selected
    }
    
    private func updateAppearance() {
            if isJobSelected {
                layer.borderColor = UIColor.systemBlue.cgColor
                layer.borderWidth = 2
                backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
            }
        }
}
