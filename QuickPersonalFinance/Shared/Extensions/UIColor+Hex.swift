//
//  UIColor+Hex.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import UIKit

extension UIColor {
    /// Create UIColor using an hex value
    /// Source: https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
    /// - Parameter hex: hexadecimal value
    convenience init?(hex: String) {
        let red, green, blue, alpha: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    blue = CGFloat(hexNumber & 0x0000ff) / 255
                    alpha = CGFloat(1.0)

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }

        return nil
    }
}
