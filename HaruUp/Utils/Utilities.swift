//
//  Utilies.swift
//  HaruUp
//
//  Created by 하다현 on 11/28/25.
//

import UIKit

class Utilities {
    func inputContainerView(withImage image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        let iv = UIImageView()
        
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        iv.image = image
        iv.tintColor = .black
        
        view.addSubview(iv)
        iv.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 8, paddingBottom: 7 )
        iv.setDimensions(width: 24, height: 24)
        
        
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, paddingBottom: 7)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .gray
        view.addSubview(dividerView)
        dividerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 0.75)
        
        return view
    }
    
    func textField(withPlaceholder placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 16)
        
        return tf
    }
}
