//
//  Font+Report.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/5/23.
//

import SwiftUI

extension Font {
    struct Report {
        static let mainTitle: Font = .custom("WorkSans-Light", size: 24)
        static let title1: Font = .custom("WorkSans-Medium", size: 20)
        static let title2: Font = .custom("WorkSans-Medium", size: 18)
        static let standard: Font = .custom("WorkSans-Light", size: 14)
        static let trademark: Font = .custom("WorkSans-Light", size: 8)
        static let info: Font = .custom("WorkSans-Italic", size: 10)
        private init() {}
    }
}
