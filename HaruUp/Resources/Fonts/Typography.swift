//
//  Typography.swift
//  HaruUp
//
//  Created by 조영현 on 12/16/25.
//

import UIKit

struct FontStyle {
    let font: UIFont
    let lineHeight: CGFloat // 150 %

    init(font: UIFont, lineHeight: CGFloat = 1.50) {
        self.font = font
        self.lineHeight = lineHeight
    }
}

enum Typography {
    // Head
    static let head1 = FontStyle(font: .pretendard(size: 32, weight: .bold))
    static let head2 = FontStyle(font: .pretendard(size: 30, weight: .bold), lineHeight: 1.0)
    
    // Title
    static let title1 = FontStyle(font: .pretendard(size: 24, weight: .bold))
    static let title2 = FontStyle(font: .pretendard(size: 24, weight: .semiBold))
    static let title3 = FontStyle(font: .pretendard(size: 20, weight: .semiBold))
    
    // Subtitle
    static let subtitle1 = FontStyle(font: .pretendard(size: 18, weight: .semiBold))
    static let subtitle2 = FontStyle(font: .pretendard(size: 16, weight: .semiBold))
    
    // Body
    static let body1 = FontStyle(font: .pretendard(size: 16, weight: .medium))
    static let body2 = FontStyle(font: .pretendard(size: 14, weight: .bold))
    static let body3 = FontStyle(font: .pretendard(size: 14, weight: .semiBold))
    static let body4 = FontStyle(font: .pretendard(size: 14, weight: .medium))
    static let body5 = FontStyle(font: .pretendard(size: 13, weight: .medium))
    
    // Footnote
    static let footnote = FontStyle(font: .pretendard(size: 13, weight: .regular))
    
    // Caption
    static let caption1 = FontStyle(font: .pretendard(size: 12, weight: .semiBold))
    static let caption2 = FontStyle(font: .pretendard(size: 12, weight: .medium))
    static let caption3 = FontStyle(font: .pretendard(size: 12, weight: .regular))
    
    // Level
    static let level = FontStyle(font: .pretendard(size: 13, weight: .semiBold))
    
    // Difficulty
    static let difficulty = FontStyle(font: .pretendard(size: 14, weight: .medium), lineHeight: 1.40)
    // Exp
    static let exp = FontStyle(font: .pretendard(size: 14, weight: .medium), lineHeight: 1.40)
    
    // retry Button
    static let retryButton = FontStyle(font: .pretendard(size: 14, weight: .medium), lineHeight: 1.40)
    
    // Calendar
    static let calendarWeek = FontStyle(font: .pretendard(size: 13, weight: .medium), lineHeight: 1.50)
    static let calendarDay = FontStyle(font: .pretendard(size: 13, weight: .medium), lineHeight: 1.50)
    
    // Chart
    static let yText = FontStyle(font: .pretendard(size: 11, weight: .medium), lineHeight: 1.00)
    static let xText = FontStyle(font: .pretendard(size: 13, weight: .medium), lineHeight: 1.00)
}
