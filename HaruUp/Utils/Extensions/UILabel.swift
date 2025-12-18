//
//  UILabel.swift
//  HaruUp
//
//  Created by 조영현 on 12/17/25.
//

import UIKit

extension UILabel {
    /// FontStyle을 적용하는 메서드
    func setStyle(_ style: FontStyle, text: String) {
        let content = text
        let font = style.font
        
        let paragraphStyle = NSMutableParagraphStyle()
        let targetLineHeight = font.lineHeight * style.lineHeight
        paragraphStyle.minimumLineHeight = targetLineHeight
        paragraphStyle.maximumLineHeight = targetLineHeight

        // 기본 Label 생성시 설정했던 정렬 사용
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            /// 아래 수식 사용의 이유
            /// Default로 150%의 LineHeightMultiple를 사용. 이때 LineHeightMultiple는 글자가 작성되는 기준은 그대로 두고 높이만 높아지기 때문에 text가 아래로 쏠리는 느낌을 준다.
            /// 즉, 우리가 설정한 default line Height는 150% 이므로 1.5 - 1.0 즉, 0.5의 높이가 추가됨.
            /// 0.5에서 50%를 baseline에 offset을 주게되면 평소 작성하던 높이와 유사하게 구현
            .baselineOffset: (targetLineHeight - font.lineHeight) / 2
        ]
        
        self.attributedText = NSAttributedString(string: content, attributes: attributes)
    }
}
