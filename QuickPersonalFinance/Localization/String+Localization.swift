//
//  String+Localization.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 22/4/23.
//

import Foundation

// swiftlint:disable nslocalizedstring_key
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
// swiftlint:enable nslocalizedstring_key
