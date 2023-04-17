//
//  IncomeActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/3/23.
//

import Foundation
import CoreData

extension IncomeActionView {

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
                nameTextErrorMessage = "A name is required to identify this source of income"
                isValid = false
            } else {
                nameTextErrorMessage = nil
            }

            let grossValueValidation = DoubleValidation(value: grossValueText)
            if grossValueText.isEmpty || !grossValueValidation.isValid {
                grossValueErrorMessage = "A gross income value is required"
                isValid = false
            } else {
                grossValueErrorMessage = nil
            }

            if isValid, let oldData = mainData, let moc {
                let income = Income(
                    name: nameText,
                    more: moreText.isEmpty ? nil : moreText,
                    grossValue: Double(grossValueText)!,
                    recurrence: selectedRecurrence
                )
                var incomes = oldData.financeData.incomes
                incomes.append(income)
                let financeData = FinanceData(
                    incomes: incomes,
                    expenses: oldData.financeData.expenses
                )
                mainData?.financeData = financeData
                let _ = StoredIncome.from(income, context: moc)
                try? moc.save()
                didSubmit(true)
                return
            }

            didSubmit(false)
        }
    }

}
