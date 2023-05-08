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
        var editingIncome: Income? {
            didSet {
                guard let editingIncome else {
                    return
                }
                nameText = editingIncome.name
                moreText = editingIncome.more ?? ""
                grossValueText = String(editingIncome.grossValue)
                selectedRecurrence = editingIncome.recurrence ?? .hour
            }
        }
        var currencyCode: String {
            Locale.current.currency?.identifier ?? "USD"
        }

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.persistenceService = IncomePersistence(moc: moc)
        }

        func validate() -> Bool {
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

            return isValid
        }

        func submit(_ didSubmit: (Bool) -> Void) {
            let isValid = validate()

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

        func edit(_ didEdit: (Bool) -> Void) {
            let isValid = validate()

            if let editingIncome, isValid, let oldData = mainData {
                let income = Income(
                    id: editingIncome.id,
                    name: nameText,
                    more: moreText.isEmpty ? nil : moreText,
                    grossValue: Double(grossValueText)!,
                    recurrence: selectedRecurrence
                )

                persistenceService?.update(item: income)
                guard let incomes = persistenceService?.loadAll() else {
                    didEdit(false)
                    return
                }

                let financeData = FinanceData(
                    incomes: incomes,
                    expenses: oldData.financeData.expenses
                )
                mainData?.financeData = financeData

                didEdit(true)
                return
            }

            didEdit(false)
        }
    }

}
