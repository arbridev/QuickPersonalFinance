//
//  Color+Palette.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import SwiftUI

extension Color {
    struct Palette {
        struct Base {
            static let red = hex("#F05B75")
            static let green = hex("#27b83a")
            static let blue = hex("#506EE0")
            static let blue2 = hex("#5299e0")
            static let purple = hex("#BC57FA")
            static let gray0 = hex("#aebbc7")
            static let gray1 = hex("#ccd5db")
            static let gray2 = hex("#e1e6ea")

            private init() {}

            private static func hex(_ value: String) -> Color {
                guard let color = UIColor(hex: value) else {
                    assertionFailure("Invalid hex color: \(value)")
                    return .clear
                }
                return Color(uiColor: color)
            }
        }

        static let incomeAccent = Color("incomeAccent")
        static let expenseAccent = Color("expenseAccent")
        static let estimateAccent = Color("estimateAccent")
        static let estimateAccentSecondary = Color("estimateAccentSecondary")
        static let incomeTable = Color("incomeTable")
        static let expenseTable = Color("expenseTable")
        static let dividerPrimary = Color("dividerPrimary")
        static let dividerSecondary = Color("dividerSecondary")
        static let iconPrimary = Color("iconPrimary")
        static let textFieldOutline = Color("textFieldOutline")

        private init() {}
    }
}
