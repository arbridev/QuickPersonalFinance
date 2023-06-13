//
//  EstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import Foundation

extension EstimateView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published private(set) var mainData: AppData? {
            didSet {
                calculations = Calculation()
            }
        }
        @Published var incomeTotal: Double = 0.0
        @Published var expenseTotal: Double = 0.0
        @Published var balance: Double = 0.0
        @Published var selectedRecurrence: Recurrence = .year {
            didSet {
                update()
            }
        }
        @Published var barChartData: [BarValue] = [BarValue]()
        @Published var isPresentingSettings = false {
            didSet {
                if !isPresentingSettings {
                    update()
                }
            }
        }
        @Published var isPresentingCurrencyConversion = false
        
        private let settings: SettingsService
        private var calculations: CalculationService?

        var balanceInfoMessage: String {
            String(
                format: "estimate.balance.info.message".localized,
                currencyID,
                selectedRecurrence.rawValue.localized
            )
        }

        var shareMessage: String {
            if balance > 0.0 {
                return String(
                    format: "estimate.share.message.save".localized,
                    selectedRecurrence.rawValue.localized,
                    incomeTotal.asCurrency(withID: currencyID),
                    expenseTotal.asCurrency(withID: currencyID),
                    balance.asCurrency(withID: currencyID),
                    currencyID
                )
            } else {
                return String(
                    format: "estimate.share.message.lose".localized,
                    selectedRecurrence.rawValue.localized,
                    incomeTotal.asCurrency(withID: currencyID),
                    expenseTotal.asCurrency(withID: currencyID),
                    balance.asCurrency(withID: currencyID),
                    currencyID
                )
            }
        }

        var currencyID: String {
            settings.currencyID
        }

        init() {
            settings = Settings()
        }

        // MARK: Behavior

        func input(mainData: AppData) {
            self.mainData = mainData
        }

        func update() {
            guard let mainData else {
                return
            }
            incomeTotal = calculations!.totalize(
                sources: mainData.financeData.incomes,
                to: selectedRecurrence
            )
            expenseTotal = calculations!.totalize(
                sources: mainData.financeData.expenses,
                to: selectedRecurrence
            )
            balance = incomeTotal - expenseTotal
            createChartData()
        }

        private func createChartData() {
            guard mainData != nil else {
                return
            }
            let barChartData = [
                BarValue(title: "estimate.table.income".localized, total: incomeTotal),
                BarValue(title: "estimate.table.expense".localized, total: expenseTotal)
            ]
            self.barChartData = barChartData
        }
    }

}

// MARK: - Bar value

extension EstimateView {
    struct BarValue {
        let title: String
        let total: Double
    }
}
