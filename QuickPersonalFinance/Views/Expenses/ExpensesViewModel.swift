//
//  ExpensesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import CoreData

extension ExpensesView {

    @MainActor class ViewModel: ObservableObject {
        @Published var mainData: AppData?
        @Published var isPresentingCreateAction = false
        @Published var isPresentingEditAction = false
        @Published var selectedItem: Expense? {
            didSet {
                isPresentingEditAction.toggle()
            }
        }
        var moc: NSManagedObjectContext?
        var persistenceService: (any ExpensePersistenceService)?
        var currencyCode: String {
            Locale.current.currency?.identifier ?? "USD"
        }

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.persistenceService = ExpensePersistence(moc: moc)
        }

        func deleteItems(at offsets: IndexSet) {
            guard let oldData = mainData else {
                return
            }
            var expenses = oldData.financeData.expenses
            expenses.remove(atOffsets: offsets)

            let forDeletion = oldData.financeData.expenses.difference(from: expenses)

            let financeData = FinanceData(
                incomes: oldData.financeData.incomes,
                expenses: expenses
            )
            mainData?.financeData = financeData

            persistenceService?.delete(items: forDeletion)
        }
    }

}
