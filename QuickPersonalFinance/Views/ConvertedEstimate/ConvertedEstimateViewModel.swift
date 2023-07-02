//
//  ConvertedEstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/5/23.
//

import Foundation
import CoreData

extension ConvertedEstimateView {

    @MainActor class ViewModel: ObservableObject {
        @Published var pickerSelectedCurrency = Constant.defaultCurrencyID {
            didSet {
                Task.detached(priority: .background) {
                    do {
                        try await self.setConversion()
                        await self.setErrorMessage(nil)
                    } catch {
                        if let error = error as? Calculation.CurrencyCalculationError {
                            await self.setErrorMessage(error.localizedDescription)
                        } else {
                            await self.setErrorMessage(StandardError.unknown.localizedDescription)
                        }
                    }
                }
            }
        }
        @Published var selectedCurrency = Constant.defaultCurrencyID
        @Published var incomeTotal: Double = 0.0
        @Published var expenseTotal: Double = 0.0
        @Published var balance: Double = 0.0
        @Published var isErrorPresented = false
        @Published var errorMessage: String?
        @Published var isRefreshing = false

        let settings: Settings

        var financeData: FinanceData?
        var recurrence: Recurrence?
        var rate = 1.0
        var baseCurrencyID: String {
            settings.currencyID
        }

        var balanceInfoMessage: String {
            String(
                format: "estimate.balance.info.message".localized,
                selectedCurrency,
                recurrence?.rawValue.localized ?? ""
            )
        }
        var moc: NSManagedObjectContext?
        var persistenceService: (any CurrencyDataService)?
        var externalService: (any ExternalCurrencyService)?
        var currencyIDs: [String] = Locale.Currency.isoCurrencies.map({ $0.identifier })
        let currencyRefresh: CurrencyRefresh = .after(Constant.currencyRefreshInterval)

        init() {
            settings = Settings()
        }

        func input(
            financeData: FinanceData,
            recurrence: Recurrence,
            moc: NSManagedObjectContext
        ) {
            self.financeData = financeData
            self.recurrence = recurrence
            self.moc = moc
            self.selectedCurrency = settings.currencyID
            externalService = ExternalCurrency()
            persistenceService = CurrencyDataPersistence(moc: moc)
            setInitialState()
        }

        private func setInitialState() {
            guard let financeData, let recurrence else {
                return
            }
            let calculation = Calculation()
            
            incomeTotal = calculation.totalize(
                sources: financeData.incomes,
                to: recurrence
            )
            expenseTotal = calculation.totalize(
                sources: financeData.expenses,
                to: recurrence
            )
            balance = calculation.makeBalance(
                incomes: financeData.incomes,
                expenses: financeData.expenses,
                basedOn: recurrence
            )
        }

        private func setConversion() async throws {
            setInitialState()
            let userCurrency = settings.currencyID
            guard userCurrency != pickerSelectedCurrency else {
                return
            }
            guard let converter = try await makeCurrencyCalculationService() else {
                return
            }
            incomeTotal = try converter.convert(incomeTotal, from: userCurrency, to: pickerSelectedCurrency)
            expenseTotal = try converter.convert(expenseTotal, from: userCurrency, to: pickerSelectedCurrency)
            balance = try converter.convert(balance, from: userCurrency, to: pickerSelectedCurrency)
            selectedCurrency = pickerSelectedCurrency
        }

        private func makeCurrencyCalculationService() async throws -> CurrencyCalculationService? {
            guard let persistenceService else {
                return nil
            }
            if let currencyData = persistenceService.load() {
                switch currencyRefresh {
                    case .after(let interval):
                        let timeLimit = currencyData.meta.lastUpdatedAt.addingTimeInterval(interval)
                        if Date.now > timeLimit {
                            let latestCurrencies = try await fetchCurrencies()
                            persistenceService.save(item: latestCurrencies)
                            return Calculation.CurrencyCalculation(latestCurrencies.data)
                        }
                    case .always:
                        let latestCurrencies = try await fetchCurrencies()
                        persistenceService.save(item: latestCurrencies)
                        return Calculation.CurrencyCalculation(latestCurrencies.data)
                    case .never:
                        break
                }
                return Calculation.CurrencyCalculation(currencyData.data)
            } else {
                let latestCurrencies = try await fetchCurrencies()
                persistenceService.save(item: latestCurrencies)
                return Calculation.CurrencyCalculation(latestCurrencies.data)
            }
        }

        private func fetchCurrencies() async throws -> LatestCurrencies {
            guard let externalService else {
                return LatestCurrencies(meta: Meta(lastUpdatedAt: .now), data: [:])
            }
            isRefreshing = true
            defer {
                isRefreshing = false
            }
            return try await externalService.fetchLatestCurrencies()
        }

        private func setErrorMessage(_ message: String?) {
            errorMessage = message
            isErrorPresented = message == nil ? false : true
        }
    }

    enum CurrencyRefresh {
        case never
        case always
        case after(TimeInterval)
    }
}
