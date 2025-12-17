//
//  UIFont.swift
//  HaruUp
//
//  Created by 조영현 on 12/16/25.
//

import UIKit

extension UIFont {
    enum PretendardWeight: String {
        case bold = "Pretendard-Bold"
        case semiBold = "Pretendard-SemiBold"
        case medium = "Pretendard-Medium"
        case regular = "Pretendard-Regular"
    }
    
    static func pretendard(size: CGFloat, weight: PretendardWeight) -> UIFont {
        guard let font = UIFont(name: weight.rawValue, size: size) else {
            return .systemFont(ofSize: size, weight: .regular) // default font
        }
        
        return font
    }
}
