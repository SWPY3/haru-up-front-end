//
//  UIImage.swift
//  HaruUp
//
//  Created by 조영현 on 12/30/25.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }.withRenderingMode(.alwaysOriginal)
    }
}
