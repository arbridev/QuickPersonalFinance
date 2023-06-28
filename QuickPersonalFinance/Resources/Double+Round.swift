//
//  Double+Round.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 28/6/23.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    /// source: https://stackoverflow.com/a/32581409/5691990
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
