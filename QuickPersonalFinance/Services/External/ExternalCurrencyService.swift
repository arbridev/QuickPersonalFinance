//
//  ExternalCurrencyService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/6/23.
//

import Foundation

protocol ExternalCurrencyService: Actor {
    func fetchLatestCurrencies() async -> LatestCurrencies?
}

actor ExternalCurrency: ExternalCurrencyService {
    func fetchLatestCurrencies() -> LatestCurrencies? {
        MockData.latestCurrencies
    }
}

fileprivate extension URL {
    struct Endpoint {
        static let latest = ""
        private init() {}
    }
}
