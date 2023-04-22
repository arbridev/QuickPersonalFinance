//
//  EstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import Foundation

extension EstimateView {

    @MainActor class ViewModel: ObservableObject {
        private var calculations: CalculationService?

        @Published var mainData: AppData? {
            didSet {
                guard let mainData else {
                    return
                }
                calculations = Calculation(
                    incomes: mainData.financeData.incomes,
                    expenses: mainData.financeData.expenses
                )
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
        }

        func createChartData() {
            guard let _ = mainData else {
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

extension EstimateView {
    struct BarValue {
        let title: String
        let total: Double
    }
}
