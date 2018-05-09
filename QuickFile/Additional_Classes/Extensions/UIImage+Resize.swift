//
//  UIImage+Resize.swift
//  QuickFile
//
//  Created by Yurii Boiko on 5/9/18.
//  Copyright © 2018 Yurii Boiko. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(scaleFactor: CGFloat) -> UIImage {
        let targetSize = size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(targetSize, !hasAlpha, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: targetSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }

    func resize(to targetSize: CGSize) -> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(targetSize, !hasAlpha, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: targetSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
