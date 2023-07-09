//
//  CurrencyConversionController.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 3/7/23.
//

import Foundation
import CoreData

protocol CurrencyControl where Self: Actor {
    func makeCurrencyCalculationService() async throws -> CurrencyCalculationService?
}

/// Controller for currency conversion operations.
actor CurrencyConversionController: CurrencyControl {

    // MARK: Properties

    let currencyRefresh: CurrencyRefresh = .after(Constant.currencyRefreshInterval)
    let persistenceService: CurrencyDataService
    let externalService: ExternalCurrencyService
    var userData: UserDataService

    // MARK: Initialization

    init(
        persistenceService: CurrencyDataService,
        externalService: ExternalCurrencyService,
        userData: UserDataService
    ) {
        self.persistenceService = persistenceService
        self.externalService = externalService
        self.userData = userData
    }

    // MARK: Behavior

    /// Factory method for a calculation service.
    /// - Returns: A currency calculation service ready to be used.
    func makeCurrencyCalculationService() async throws -> CurrencyCalculationService? {
        if let currencyData = persistenceService.load() {
            switch currencyRefresh {
                case .after(let interval):
                    guard let timeLimit = userData.lastCurrencyUpdate?.addingTimeInterval(interval) else {
                        let latestCurrencies = try await updateCurrencies()
                        return Calculation.CurrencyCalculation(latestCurrencies.data)
                    }
                    if Date.now > timeLimit {
                        let latestCurrencies = try await updateCurrencies()
                        return Calculation.CurrencyCalculation(latestCurrencies.data)
                    }
                case .always:
                    let latestCurrencies = try await updateCurrencies()
                    return Calculation.CurrencyCalculation(latestCurrencies.data)
                case .never:
                    break
            }
            return Calculation.CurrencyCalculation(currencyData.data)
        } else {
            let latestCurrencies = try await updateCurrencies()
            return Calculation.CurrencyCalculation(latestCurrencies.data)
        }
    }

    /// Updates the currency data to be used for operations by fetching from external sources and persisting.
    /// - Returns: Data from currencies as structured in LatestCurrencies.
    private func updateCurrencies() async throws -> LatestCurrencies {
        let latestCurrencies = try await externalService.fetchLatestCurrencies()
        persistenceService.save(item: latestCurrencies)
        userData.lastCurrencyUpdate = .now
        return latestCurrencies
    }
}
