//
//  ExpensesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import Foundation
import CoreData

extension ExpensesView {

    @MainActor class ViewModel: ObservableObject {
        @Published var mainData: AppData?
        var moc: NSManagedObjectContext?

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

            for expense in forDeletion {
                let request = NSFetchRequest<StoredExpense>(entityName: "\(StoredExpense.self)")
                request.predicate = NSPredicate(
                    format: "name == %@ AND grossValue == %@",
                    argumentArray: [expense.name, expense.grossValue]
                )
                if let fetchedObject = try? moc?.fetch(request).first {
                    moc?.delete(fetchedObject)
                }
            }
            try? moc?.save()
        }
    }

}