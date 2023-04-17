//
//  ExpenseActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 7/4/23.
//

import Foundation
import CoreData

extension ExpenseActionView {

    @MainActor class ViewModel: ObservableObject {
        @Published var mainData: AppData?
        @Published var nameText: String = ""
        @Published var moreText: String = ""
        @Published var grossValueText: String = "" {
            didSet {
                let preemptiveValidation = DoubleValidation(value: grossValueText)
                if !preemptiveValidation.isValid {
                    grossValueText = oldValue
                }
            }
        }
        @Published var selectedRecurrence: Recurrence = .hour
        @Published var nameTextErrorMessage: String?
        @Published var grossValueErrorMessage: String?
        var moc: NSManagedObjectContext?

        func submit(_ didSubmit: (Bool) -> Void) {
            var isValid = true
            if nameText.isEmpty {
                nameTextErrorMessage = "A name is required to identify this source of expense"
                isValid = false
            } else {
                nameTextErrorMessage = nil
            }

            let grossValueValidation = DoubleValidation(value: grossValueText)
            if grossValueText.isEmpty || !grossValueValidation.isValid {
                grossValueErrorMessage = "A gross expense value is required"
                isValid = false
            } else {
                grossValueErrorMessage = nil
            }

            if isValid, let oldData = mainData, let moc {
                let expense = Expense(
                    name: nameText,
                    more: moreText.isEmpty ? nil : moreText,
                    grossValue: Double(grossValueText)!,
                    recurrence: selectedRecurrence
                )
                var expenses = oldData.financeData.expenses
                expenses.append(expense)
                let financeData = FinanceData(
                    incomes: oldData.financeData.incomes,
                    expenses: expenses
                )
                mainData?.financeData = financeData
                let _ = StoredExpense.from(expense, context: moc)
                try? moc.save()
                didSubmit(true)
                return
            }

            didSubmit(false)
        }
    }

}
