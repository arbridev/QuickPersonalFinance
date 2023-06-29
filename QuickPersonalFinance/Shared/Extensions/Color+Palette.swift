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
            static let red = Color(uiColor: UIColor(hex: "#F05B75")!)
            static let green = Color(uiColor: UIColor(hex: "#27b83a")!)
            static let blue = Color(uiColor: UIColor(hex: "#506EE0")!)
            static let blue2 = Color(uiColor: UIColor(hex: "#5299e0")!)
            static let purple = Color(uiColor: UIColor(hex: "#BC57FA")!)
            static let gray0 = Color(uiColor: UIColor(hex: "#aebbc7")!)
            static let gray1 = Color(uiColor: UIColor(hex: "#ccd5db")!)
            static let gray2 = Color(uiColor: UIColor(hex: "#e1e6ea")!)

            private init() {}
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
