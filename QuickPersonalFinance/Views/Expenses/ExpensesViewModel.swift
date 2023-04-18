//
//  ExpensesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import Foundation

extension ExpensesView {

    @MainActor class ViewModel: ObservableObject {
        @Published var mainData: AppData?

        func deleteItems(at offsets: IndexSet) {
            guard let oldData = mainData else {
                return
            }
            var expenses = oldData.financeData.expenses
            expenses.remove(atOffsets: offsets)
            let financeData = FinanceData(
                incomes: oldData.financeData.incomes,
                expenses: expenses
            )
            mainData?.financeData = financeData
        }
    }

}
