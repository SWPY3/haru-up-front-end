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
    
    /// 전체 스타일(폰트/라인하이트) 적용 + 특정 텍스트만 색 변경
    func setStyledText(_ style: FontStyle, fullText: String, highlightedText: String, highlightedColor: UIColor, defaultColor: UIColor, highlightedFont: UIFont? = nil) {
        self.textColor = defaultColor
        self.numberOfLines = 0

        let baseFont = style.font

        let paragraphStyle = NSMutableParagraphStyle()
        let targetLineHeight = baseFont.lineHeight * style.lineHeight
        paragraphStyle.minimumLineHeight = targetLineHeight
        paragraphStyle.maximumLineHeight = targetLineHeight
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode

        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: (targetLineHeight - baseFont.lineHeight) / 2,
            .foregroundColor: defaultColor
        ]

        let attributed = NSMutableAttributedString(string: fullText, attributes: baseAttributes)

        // highlightedText 범위 찾아서 속성 변경
        let nsText = fullText as NSString
        let range = nsText.range(of: highlightedText)
        
        if range.location != NSNotFound {
            attributed.addAttribute(.foregroundColor, value: highlightedColor, range: range)
            
            if let hFont = highlightedFont {
                attributed.addAttribute(.font, value: hFont, range: range)
            }
        }

        self.attributedText = attributed
    }
    
    /// 텍스트에 취소선을 긋거나 제거하는 함수
    func setStrikethrough(_ isActive: Bool, color: UIColor? = nil) {
        guard let text = self.text else { return }
        
        let attributedString: NSMutableAttributedString
        
        // 이미 attributedText가 있다면 그것을 기반으로, 없다면 일반 text를 기반으로 생성
        if let currentAttr = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: currentAttr)
        } else {
            attributedString = NSMutableAttributedString(string: text)
        }
        
        let range = NSMakeRange(0, attributedString.length)
        
        if isActive {
            // 취소선 추가
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            // (선택) 색상을 회색 등으로 변경하고 싶다면 함께 적용
            if let color = color {
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
        } else {
            // 취소선 제거 (셀 재사용 시 필수)
            attributedString.removeAttribute(.strikethroughStyle, range: range)
            // 색상을 원래대로 돌리려면 별도 처리가 필요하거나, configure에서 textColor를 다시 지정해야 합니다.
        }
        
        self.attributedText = attributedString
    }
}
