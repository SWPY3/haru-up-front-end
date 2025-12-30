//
//  UITextField.swift
//  HaruUp
//
//  Created by 조영현 on 12/30/25.
//

import UIKit

extension UITextField {
    func setPlaceholder(color: UIColor) {
        guard let string = self.placeholder else { return }
        
        attributedPlaceholder = NSAttributedString(string: string, attributes: [.foregroundColor: color])
    }
}
