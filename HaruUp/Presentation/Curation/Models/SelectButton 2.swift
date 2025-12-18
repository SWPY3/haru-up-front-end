//
//  SelectButton.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit

class SelectButton: UIButton {
    
    private var buttonIsSelected: Bool = false {
        didSet {
            print("버튼: \(self.titleLabel?.text ?? ""), 선택 상태: \(isSelected)")
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
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
        contentHorizontalAlignment = .left
        self.configuration = configuration
    }
    
    func setSelected(_ selected: Bool) {
        buttonIsSelected = selected
    }
    
    private func updateAppearance() {
            if buttonIsSelected {
                layer.borderColor = UIColor.systemBlue.cgColor
                layer.borderWidth = 2
                backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
            } else {
                layer.borderColor = nil
                layer.borderWidth = 0
                backgroundColor = .systemGray6
            }
        }
}
