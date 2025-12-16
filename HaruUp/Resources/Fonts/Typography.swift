//
//  Typography.swift
//  HaruUp
//
//  Created by 조영현 on 12/16/25.
//

import UIKit

struct FontStyle {
    let font: UIFont
    let lineHeight: CGFloat = 1.50 // 150 %
}

enum Typography {
    // Head
    static let head1 = FontStyle(font: .pretendard(size: 32, weight: .bold))
    
    // Title
    static let title1 = FontStyle(font: .pretendard(size: 24, weight: .bold))
    static let title2 = FontStyle(font: .pretendard(size: 24, weight: .semiBold))
    static let title3 = FontStyle(font: .pretendard(size: 20, weight: .semiBold))
    
    // Subtitle
    static let subtitle1 = FontStyle(font: .pretendard(size: 18, weight: .semiBold))
    static let subtitle2 = FontStyle(font: .pretendard(size: 16, weight: .semiBold))
    
    // Body
    static let body1 = FontStyle(font: .pretendard(size: 16, weight: .medium))
    static let body2 = FontStyle(font: .pretendard(size: 14, weight: .semiBold))
    static let body3 = FontStyle(font: .pretendard(size: 14, weight: .medium))
    
    // Caption
    static let caption1 = FontStyle(font: .pretendard(size: 12, weight: .medium))
    static let caption2 = FontStyle(font: .pretendard(size: 12, weight: .regular))
    
    // Level
    static let level = FontStyle(font: .pretendard(size: 13, weight: .semiBold))
}
