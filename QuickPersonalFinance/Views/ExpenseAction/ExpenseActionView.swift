//
//  ExpenseActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpenseActionView: View {

    // MARK: Nested types

    enum Field {
        case name, more, grossValue
    }

    // MARK: Properties

    @EnvironmentObject private var mainData: AppData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var moc

    @StateObject private var viewModel = ViewModel()
    @FocusState private var focusedField: Field?

    var editingExpense: Expense?
    
    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(
                title: editingExpense == nil ?
                "expense.action.create.title" :
                    "expense.action.edit.title",
                dismiss: dismiss
            )
            Spacer()
            // MARK: Content
            VStack {
                Form {
                    CustomTextField(
                        text: $viewModel.nameText,
                        errorMessage: $viewModel.nameTextErrorMessage,
                        placeholder: "action.field.name".localized,
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .padding(.top, 4)
                    .listRowSeparator(.hidden)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)

                    CustomTextField(
                        text: $viewModel.moreText,
                        errorMessage: Binding.constant(nil),
                        placeholder: "action.field.more".localized,
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .listRowSeparator(.hidden)
                    .focused($focusedField, equals: .more)

                    CustomTextField(
                        text: $viewModel.grossValueText,
                        errorMessage: $viewModel.grossValueErrorMessage,
                        placeholder: "action.field.gross.value".localized,
                        prefix: viewModel.currencyID,
                        prefixColor: .Palette.expenseAccent,
                        keyboardType: .decimalPad
                    )
                    .listRowSeparator(.hidden)
                    .focused($focusedField, equals: .grossValue)
                    .onChange(of: focusedField) { newFocusedField in
                        if newFocusedField == .grossValue {
                            if let number = Double(viewModel.grossValueText),
                                number == 0.0 {
                                viewModel.grossValueText = ""
                            }
                        }
                    }

                    Picker("\("action.field.recurrence".localized):", selection: $viewModel.selectedRecurrence) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.localized.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .padding(.bottom, 4)
                    .font(.App.input)

                    if editingExpense != nil {
                        CTAButton(title: "action.button.edit".localized, color: .Palette.expenseAccent) {
                            viewModel.edit { didEdit in
                                if didEdit {
                                    dismiss.callAsFunction()
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    } else {
                        CTAButton(title: "action.button.submit".localized, color: .Palette.expenseAccent) {
                            viewModel.submit { didSubmit in
                                if didSubmit {
                                    dismiss.callAsFunction()
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.input(mainData: mainData, moc: moc)
            viewModel.editingExpense = editingExpense
        }
    }

    // MARK: Initialization

    init() {}

    init(editingExpense: Expense) {
        self.editingExpense = editingExpense
    }
}

// MARK: - Previews

struct ExpenseActionView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        data.financeData = FinanceData(incomes: [Income](), expenses: [Expense]())
        return data
    }

    static var previews: some View {
        ExpenseActionView()
            .environmentObject(envObject)
    }
}
