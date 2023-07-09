//
//  ConvertedEstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/5/23.
//

import CoreData

extension ConvertedEstimateView {

    ///  View model for converted estimate view
    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

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
        var controller: (any CurrencyControl)?
        var currencyIDs: [String] = Constant.currencyIDs

        // MARK: Initialization

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

            if LaunchArguments.shared.contains(.testing) {
                controller = MockCurrencyController()
                currencyIDs = MockData.currencyIDs
            } else {
                externalService = ExternalCurrency()
                persistenceService = CurrencyDataPersistence(moc: moc)
                controller = CurrencyConversionController(
                    persistenceService: persistenceService!,
                    externalService: externalService!,
                    userData: userData
                )
            }
            setInitialState()
        }

        // MARK: Behavior

        /// Set an initial state based on the base currency set by an user.
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

        /// Sets the data converted between currencies, after calculating and updating.
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
                HapticsService().notificationFeedback(.error)
            }
        }
    }
}
