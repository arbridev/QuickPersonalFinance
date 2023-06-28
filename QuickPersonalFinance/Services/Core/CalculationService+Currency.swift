//
//  CalculationService+Currency.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 28/6/23.
//

import Foundation

protocol CurrencyCalculationService {
    var baseCurrency: Currency { get }
    var currencies: [String: Currency] { get }

    init?(_ currencies: [String: Currency])

    /// Convert between currencies.
    /// - Parameters:
    ///   - value: the value to be converted.
    ///   - from: the original currency identifier.
    ///   - to: the destination currency identifier.
    func convert(_ value: Double, from originID: String, to destinationID: String) -> Double?
}

extension Calculation {
    struct CurrencyCalculation: CurrencyCalculationService {
        let baseCurrency: Currency
        let currencies: [String: Currency]

        init?(_ currencies: [String: Currency]) {
            guard let baseCurrency = currencies["USD"] else {
                return nil
            }
            self.baseCurrency = baseCurrency
            self.currencies = currencies
        }

        func convert(_ value: Double, from originID: String, to destinationID: String) -> Double? {
            guard originID != destinationID else {
                return value
            }
            guard let origin = currencies[originID],
                  let destination = currencies[destinationID] else {
                return nil
            }

            if origin.code == baseCurrency.code {
                return value * destination.value
            } else if destination.code == baseCurrency.code {
                return value / origin.value
            } else {
                if let originUSD = convert(value, from: origin.code, to: baseCurrency.code) {
                    return convert(originUSD, from: baseCurrency.code, to: destinationID)
                }
            }

            return nil
        }
    }
}
