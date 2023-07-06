//
//  ExpenseActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 7/4/23.
//

import CoreData

extension ExpenseActionView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var mainData: AppData?
        @Published var nameText: String = "" {
            didSet {
                if nameText.count > Constant.maxLengthNameField {
                    nameText = oldValue
                }
            }
        }
        @Published var moreText: String = "" {
            didSet {
                if moreText.count > Constant.maxLengthMoreField {
                    moreText = oldValue
                }
            }
        }
        @Published var grossValueText: String = "" {
            didSet {
                let preemptiveValidation = DoubleValidation(value: grossValueText)
                if !preemptiveValidation.isValid {
                    grossValueText = oldValue
                }
                if grossValueText.count > Constant.maxLengthValueField {
                    grossValueText = oldValue
                }
            }
        }
        @Published var selectedRecurrence: Recurrence = .hour {
            didSet {
                HapticsService().selectionFeedback()
            }
        }
        @Published var nameTextErrorMessage: String?
        @Published var grossValueErrorMessage: String?

        private let settings: SettingsService
        var moc: NSManagedObjectContext?
        var persistenceService: (any ExpensePersistenceService)?

        var editingExpense: Expense? {
            didSet {
                guard let editingExpense else {
                    return
                }
                nameText = editingExpense.name
                moreText = editingExpense.more ?? ""
                grossValueText = String(editingExpense.grossValue)
                selectedRecurrence = editingExpense.recurrence ?? .hour
            }
        }
        
        var currencyID: String {
            settings.currencyID
        }

        init() {
            settings = Settings()
        }

        // MARK: Behavior

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.persistenceService = ExpensePersistence(moc: moc)
        }

        func validate() -> Bool {
            var isValid = true
            if nameText.isEmpty {
                nameTextErrorMessage = "expense.validation.error.empty.name".localized
                isValid = false
            } else {
                nameTextErrorMessage = nil
            }

            let grossValueValidation = DoubleValidation(value: grossValueText)
            if grossValueText.isEmpty || !grossValueValidation.isValid {
                grossValueErrorMessage = "expense.validation.error.gross.value".localized
                isValid = false
            } else {
                grossValueErrorMessage = nil
            }

            return isValid
        }

        func submit(_ didSubmit: (Bool) -> Void) {
            let isValid = validate()

            if isValid, let oldData = mainData {
                let expense = Expense(
                    id: UUID(),
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

                persistenceService?.save(item: expense)

                didSubmit(true)
                return
            }

            didSubmit(false)
        }

        func edit(_ didEdit: (Bool) -> Void) {
            let isValid = validate()

            if let editingExpense, isValid, let oldData = mainData {
                let expense = Expense(
                    id: editingExpense.id,
                    name: nameText,
                    more: moreText.isEmpty ? nil : moreText,
                    grossValue: Double(grossValueText)!,
                    recurrence: selectedRecurrence
                )

                persistenceService?.update(item: expense)
                guard let expenses = persistenceService?.loadAll() else {
                    didEdit(false)
                    return
                }

                let financeData = FinanceData(
                    incomes: oldData.financeData.incomes,
                    expenses: expenses
                )
                mainData?.financeData = financeData

                didEdit(true)
                return
            }

            didEdit(false)
        }
    }

}
