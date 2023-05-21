//
//  ContentViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 20/4/23.
//

import CoreData

extension ContentView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var mainData: AppData?

        var moc: NSManagedObjectContext?
        var incomePersistenceService: (any IncomePersistenceService)?
        var expensePersistenceService: (any ExpensePersistenceService)?

        // MARK: Behavior

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.moc = moc
            incomePersistenceService = IncomePersistence(moc: moc)
            expensePersistenceService = ExpensePersistence(moc: moc)
            let storedIncomes = incomePersistenceService?.loadAll() ?? [Income]()
            let storedExpenses = expensePersistenceService?.loadAll() ?? [Expense]()
            let financeData = FinanceData(
                incomes: storedIncomes,
                expenses: storedExpenses
            )
            self.mainData?.financeData = financeData
        }
    }

}
