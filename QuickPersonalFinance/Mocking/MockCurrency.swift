//
//  MockCurrency.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/7/23.
//

import Foundation

actor MockCurrencyController: CurrencyControl {
    func makeCurrencyCalculationService() async throws -> CurrencyCalculationService? {
        MockCurrencyCalculation()
    }
}

class MockCurrencyCalculation: CurrencyCalculationService {
    var baseCurrency: Currency

    var currencies: [String: Currency]

    convenience init() {
        self.init(MockData.latestCurrencies.data)!
    }

    required init?(_ currencies: [String: Currency]) {
        baseCurrency = MockData.latestCurrencies.data[Constant.defaultCurrencyID]!
        self.currencies = currencies
    }

    func convert(_ value: Double, from originID: String, to destinationID: String) throws -> Double {
        try Calculation.CurrencyCalculation(currencies)!.convert(value, from: originID, to: destinationID)
    }
}
