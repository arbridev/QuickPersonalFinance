//
//  ContentViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 20/4/23.
//

import CoreData
import OSLog

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
            do {
                let financeData = FinanceData(
                    incomes: try incomePersistenceService?.loadAll() ?? [Income](),
                    expenses: try expensePersistenceService?.loadAll() ?? [Expense]()
                )
                self.mainData?.financeData = financeData
            } catch {
                Logger.persistence.error("Could not load finance data: \(error.localizedDescription)")
            }
        }
    }

}
