//
//  Double+Currency.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import Foundation

extension Double {
    func asCurrency(withID id: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let id {
            formatter.currencyCode = id
        }
        return formatter.string(from: NSNumber(value: self))!
    }
}
