//
//  Validations.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 7/4/23.
//

import Foundation

struct DoubleValidation: Validation {
    var value: String
    var isValid: Bool {
        value.isEmpty ? true : Double(value) != nil
    }
}

struct MoneyValidation: Validation {
    var value: String
    var isValid: Bool {
        value.isEmpty || Decimal.parseMoney(value) != nil
    }
}
