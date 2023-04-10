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
        @Published var balance: Double = 0.0

        func update() {
            balance = calculations?.monthlyBalance() ?? 0.0
        }
    }

}
