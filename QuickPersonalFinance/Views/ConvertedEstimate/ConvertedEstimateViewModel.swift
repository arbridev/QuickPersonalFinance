//
//  ConvertedEstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/5/23.
//

import Foundation

extension ConvertedEstimateView {

    @MainActor class ViewModel: ObservableObject {
        @Published var selectedCurrency = Constant.defaultCurrencyID {
            didSet {
                calculate()
            }
        }
        @Published var incomeTotal: Double = 0.0
        @Published var expenseTotal: Double = 0.0
        @Published var balance: Double = 0.0

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

        init() {
            settings = Settings()
        }

        func input(financeData: FinanceData, recurrence: Recurrence) {
            self.financeData = financeData
            self.recurrence = recurrence
            calculate()
        }

        func calculate() {
            guard let financeData, let recurrence else {
                return
            }
            let calculation = Calculation()

            let incomeTotal = calculation.totalize(sources: financeData.incomes, to: recurrence)
            self.incomeTotal = calculation.convert(incomeTotal, rate: rate)
            let expenseTotal = calculation.totalize(sources: financeData.expenses, to: recurrence)
            self.expenseTotal = calculation.convert(expenseTotal, rate: rate)
        }
    }

}
