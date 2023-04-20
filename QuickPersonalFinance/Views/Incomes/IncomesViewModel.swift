//
//  IncomesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import CoreData

extension IncomesView {

    @MainActor class ViewModel: ObservableObject {
        @Published var mainData: AppData?

        var moc: NSManagedObjectContext?
        var persistenceService: (any IncomePersistenceService)?

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.persistenceService = IncomePersistence(moc: moc)
        }

        func deleteItems(at offsets: IndexSet) {
            guard let oldData = mainData else {
                return
            }
            var incomes = oldData.financeData.incomes
            incomes.remove(atOffsets: offsets)

            let forDeletion = oldData.financeData.incomes.difference(from: incomes)

            let financeData = FinanceData(
                incomes: incomes,
                expenses: oldData.financeData.expenses
            )
            mainData?.financeData = financeData
            
            persistenceService?.delete(items: forDeletion)
        }
    }

}
