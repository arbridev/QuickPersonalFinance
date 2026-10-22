//
//  IncomeActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/3/23.
//

import Foundation
import OSLog

extension IncomeActionView {

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
        @Published var isErrorPresented = false
        @Published var errorMessage: String?

        private let settings: SettingsService
        private let persistenceService: any IncomePersistenceService

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
        
        var currencyID: String {
            settings.currencyID
        }

        init(services: AppServices) {
            settings = services.settings
            persistenceService = services.incomePersistence
        }

        // MARK: Behavior

        func input(mainData: AppData) {
            self.mainData = mainData
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
            guard validate(),
                  let oldData = mainData,
                  let grossValue = Double(grossValueText) else {
                didSubmit(false)
                return
            }

            let income = Income(
                id: UUID(),
                name: nameText,
                more: moreText.isEmpty ? nil : moreText,
                grossValue: grossValue,
                recurrence: selectedRecurrence
            )

            do {
                try persistenceService.save(item: income)
            } catch {
                presentPersistenceError(error)
                didSubmit(false)
                return
            }

            mainData?.financeData = FinanceData(
                incomes: oldData.financeData.incomes + [income],
                expenses: oldData.financeData.expenses
            )
            didSubmit(true)
        }

        func edit(_ didEdit: (Bool) -> Void) {
            guard validate(),
                  let editingIncome,
                  let oldData = mainData,
                  let grossValue = Double(grossValueText) else {
                didEdit(false)
                return
            }

            let income = Income(
                id: editingIncome.id,
                name: nameText,
                more: moreText.isEmpty ? nil : moreText,
                grossValue: grossValue,
                recurrence: selectedRecurrence
            )

            do {
                try persistenceService.update(item: income)
                mainData?.financeData = FinanceData(
                    incomes: try persistenceService.loadAll(),
                    expenses: oldData.financeData.expenses
                )
            } catch {
                presentPersistenceError(error)
                didEdit(false)
                return
            }

            didEdit(true)
        }

        private func presentPersistenceError(_ error: Error) {
            Logger.persistence.error("Could not persist income: \(error.localizedDescription)")
            errorMessage = StandardError.unknown.localizedDescription
            isErrorPresented = true
            HapticsService().notificationFeedback(.error)
        }
    }

}
