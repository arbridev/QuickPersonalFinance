//
//  ExpensesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import Foundation
import OSLog

extension ExpensesView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var mainData: AppData?
        @Published var isPresentingCreateAction = false
        @Published var selectedItem: Expense?

        private let settings: SettingsService
        private let persistenceService: any ExpensePersistenceService

        var currencyID: String {
            settings.currencyID
        }

        init(services: AppServices) {
            settings = services.settings
            persistenceService = services.expensePersistence
        }

        // MARK: Behavior

        func input(mainData: AppData) {
            self.mainData = mainData
        }

        func deleteItems(at offsets: IndexSet) {
            guard let oldData = mainData else {
                return
            }
            var expenses = oldData.financeData.expenses
            expenses.remove(atOffsets: offsets)

            let forDeletion = oldData.financeData.expenses.subtracting(expenses)

            do {
                try persistenceService.delete(items: forDeletion)
            } catch {
                Logger.persistence.error("Could not delete expenses: \(error.localizedDescription)")
                HapticsService().notificationFeedback(.error)
                return
            }

            let financeData = FinanceData(
                incomes: oldData.financeData.incomes,
                expenses: expenses
            )
            mainData?.financeData = financeData
            HapticsService().notificationFeedback(.success)
        }
    }

}
