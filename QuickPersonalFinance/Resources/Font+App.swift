//
//  Fonts.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 13/4/23.
//

import SwiftUI

extension Font {
    struct App {
        static let screenTitle: Font = .custom("WorkSans-Light", size: 24)
        static let input: Font = .custom("Manrope-Regular", size: 16)
        static let buttonTitle: Font = .custom("WorkSans-Medium", size: 18)
        static let standard: Font = .custom("WorkSans-Regular", size: 16)
        static let info: Font = .custom("WorkSans-Italic", size: 12)
        static let error: Font = .custom("Manrope-Regular", size: 12)
        private init() {}
    }

    static func app(size: CGFloat) -> Font {
        .custom("WorkSans-Regular", size: size)
    }
}
