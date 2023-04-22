//
//  String+Localization.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 22/4/23.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
