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
                    await self.convert()
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

        var settings: SettingsService
        var userData: UserDataService
        var financeData: FinanceData?
        var recurrence: Recurrence?
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
        var controller: CurrencyConversionController?
        var currencyIDs: [String] = Locale.Currency.isoCurrencies.map({ $0.identifier })

        init(
            settings: SettingsService = Settings(),
            userData: UserDataService = UserData()
        ) {
            self.settings = settings
            self.userData = userData
        }

        func input(
            financeData: FinanceData,
            recurrence: Recurrence,
            moc: NSManagedObjectContext
        ) {
            self.financeData = financeData
            self.recurrence = recurrence
            self.moc = moc
            pickerSelectedCurrency = settings.currencyID
            externalService = ExternalCurrency()
            persistenceService = CurrencyDataPersistence(moc: moc)
            controller = CurrencyConversionController(
                persistenceService: persistenceService!,
                externalService: externalService!,
                userData: userData
            )
            setInitialState()
        }

        private func setInitialState() {
            guard let financeData, let recurrence else {
                return
            }
            let calculation = Calculation()

            selectedCurrency = settings.currencyID
            
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
            guard let converter = try await controller?.makeCurrencyCalculationService() else {
                return
            }
            incomeTotal = try converter.convert(incomeTotal, from: userCurrency, to: pickerSelectedCurrency)
            expenseTotal = try converter.convert(expenseTotal, from: userCurrency, to: pickerSelectedCurrency)
            balance = try converter.convert(balance, from: userCurrency, to: pickerSelectedCurrency)
            selectedCurrency = pickerSelectedCurrency
        }

        private func setErrorMessage(_ message: String?) {
            errorMessage = message
            isErrorPresented = message == nil ? false : true
        }

        private func convert() async {
            isRefreshing = true
            defer {
                isRefreshing = false
            }

            do {
                try await setConversion()
                setErrorMessage(nil)
            } catch {
                if let error = error as? Calculation.CurrencyCalculationError {
                    setErrorMessage(error.localizedDescription)
                } else {
                    setErrorMessage(StandardError.unknown.localizedDescription)
                }
            }
        }
    }
}
