//
//  ConvertedEstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/5/23.
//

import Foundation

extension ConvertedEstimateView {

    ///  View model for converted estimate view
    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var pickerSelectedCurrency = Constant.defaultCurrencyID {
            didSet {
                conversionTask?.cancel()
                conversionTask = Task {
                    await convert()
                }
            }
        }
        @Published private(set) var summary: EstimateSummary
        @Published var isErrorPresented = false
        @Published var errorMessage: String?
        @Published var isRefreshing = false

        let currencyIDs: [String]

        private let settings: SettingsService
        private let calculation: CalculationService
        private let controller: any CurrencyControl
        private var financeData: FinanceData?
        private var recurrence: Recurrence?
        private var conversionTask: Task<Void, Never>?

        // MARK: Initialization

        init(services: AppServices) {
            settings = services.settings
            calculation = Calculation(settings: services.settings)
            controller = services.currencyControl
            currencyIDs = services.currencyIDs
            summary = EstimateSummary(
                incomeTotal: 0,
                expenseTotal: 0,
                balance: 0,
                recurrence: .year,
                currencyID: services.settings.currencyID
            )
        }

        func input(financeData: FinanceData, recurrence: Recurrence) {
            self.financeData = financeData
            self.recurrence = recurrence
            pickerSelectedCurrency = settings.currencyID
            setInitialState()
        }

        // MARK: Behavior

        /// Set an initial state based on the base currency set by an user.
        private func setInitialState() {
            guard let financeData, let recurrence else {
                return
            }
            summary = EstimateSummary(
                financeData: financeData,
                recurrence: recurrence,
                currencyID: settings.currencyID,
                calculation: calculation
            )
        }

        /// Sets the data converted between currencies, after calculating and updating.
        private func setConversion() async throws {
            setInitialState()
            let userCurrency = settings.currencyID
            guard userCurrency != pickerSelectedCurrency else {
                return
            }
            guard let converter = try await controller.makeCurrencyCalculationService() else {
                return
            }
            try Task.checkCancellation()
            summary = EstimateSummary(
                incomeTotal: try converter.convert(
                    summary.incomeTotal,
                    from: userCurrency,
                    to: pickerSelectedCurrency
                ),
                expenseTotal: try converter.convert(
                    summary.expenseTotal,
                    from: userCurrency,
                    to: pickerSelectedCurrency
                ),
                balance: try converter.convert(summary.balance, from: userCurrency, to: pickerSelectedCurrency),
                recurrence: summary.recurrence,
                currencyID: pickerSelectedCurrency
            )
        }

        /// Sets an error message that is intended to prompt the user with a dialog.
        /// - Parameter message: the error message, if nil it should hide the dialog.
        private func setErrorMessage(_ message: String?) {
            errorMessage = message
            isErrorPresented = message == nil ? false : true
        }

        /// Converts the data and shows it or prompts the user with an error,
        /// handles progress view (refreshing) update.
        private func convert() async {
            isRefreshing = true
            defer {
                if !Task.isCancelled {
                    isRefreshing = false
                }
            }

            do {
                try await setConversion()
                setErrorMessage(nil)
            } catch is CancellationError {
                return
            } catch {
                if let error = error as? Calculation.CurrencyCalculationError {
                    setErrorMessage(error.localizedDescription)
                } else {
                    setErrorMessage(StandardError.unknown.localizedDescription)
                }
                HapticsService().notificationFeedback(.error)
            }
        }
    }
}
