//
//  IncomeActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/3/23.
//

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
        var persistenceService: (any IncomePersistenceService)?

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.persistenceService = IncomePersistence(moc: moc)
        }

        func submit(_ didSubmit: (Bool) -> Void) {
            var isValid = true
            if nameText.isEmpty {
                nameTextErrorMessage = "income.validation.error.empty.name".localized
                isValid = false
            } else {
                nameTextErrorMessage = nil
            }

            let grossValueValidation = DoubleValidation(value: grossValueText)
            if grossValueText.isEmpty || !grossValueValidation.isValid {
                grossValueErrorMessage = "income.validation.error.gross.value".localized
                isValid = false
            } else {
                grossValueErrorMessage = nil
            }

            if isValid, let oldData = mainData {
                let income = Income(
                    id: UUID(),
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

                persistenceService?.save(item: income)
                
                didSubmit(true)
                return
            }

            didSubmit(false)
        }
    }

}
