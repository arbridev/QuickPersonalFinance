//
//  IncomesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import Foundation

extension IncomesView {

    @MainActor class ViewModel: ObservableObject {
        @Published var mainData: AppData?

        func deleteItems(at offsets: IndexSet) {
            guard let oldData = mainData else {
                return
            }
            var incomes = oldData.financeData.incomes
            incomes.remove(atOffsets: offsets)
            let financeData = FinanceData(
                incomes: incomes,
                expenses: oldData.financeData.expenses
            )
            mainData?.financeData = financeData
        }
    }

}
