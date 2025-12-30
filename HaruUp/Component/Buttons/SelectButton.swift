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
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        backgroundColor = .neutral10

        var configuration = Configuration.plain()
        configuration.titleAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
        
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            
            outgoing.font = Typography.body1.font
            return outgoing
        }
        
        self.configuration = configuration
        self.contentHorizontalAlignment = .left
        
        self.configuration?.baseForegroundColor = .neutral1000
    }
    
    func setSelected(_ selected: Bool) {
        self.buttonIsSelected = selected
    }
    
    private func updateAppearance() {
        guard var config = self.configuration else { return }
        
        if buttonIsSelected {
            backgroundColor = .primaryBlue50
            layer.borderWidth = 2
            layer.borderColor = UIColor.cta.cgColor
            
            config.baseForegroundColor = .cta
        } else {
            backgroundColor = .neutral10
            layer.borderColor = nil
            layer.borderWidth = 0
            
            config.baseForegroundColor = .neutral1000
        }
        
        self.configuration = config
    }
}
