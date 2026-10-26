//
//  Double+Round.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 28/6/23.
//

import Foundation

extension Decimal {
    func rounded(toPlaces places: Int) -> Decimal {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, places, .plain)
        return rounded
    }
}
