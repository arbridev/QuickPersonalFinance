//
//  IncomeActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomeActionView: View {

    // MARK: Nested types

    enum Field: Hashable {
        case name, more, grossValue
    }

    // MARK: Properties

    @EnvironmentObject private var mainData: AppData
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ViewModel
    @FocusState private var focusedField: Field?

    var editingIncome: Income?

    var body: some View {
        VStack {
            // MARK: Top bar
            ModalViewUpperBar(
                title: editingIncome == nil ?
                "income.action.create.title" :
                    "income.action.edit.title",
                dismiss: dismiss
            )
            Spacer()
            form
            Spacer()
        }
        .onAppear {
            viewModel.input(mainData: mainData)
            viewModel.editingIncome = editingIncome
        }
        .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.isErrorPresented) {
            Button("action.button.ok", role: .cancel) {}
        }
    }

    private var form: some View {
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
                prefixColor: .Palette.incomeAccent,
                keyboardType: .decimalPad
            )
            .listRowSeparator(.hidden)
            .focused($focusedField, equals: .grossValue)
            .onChange(of: focusedField) { newFocusedField in
                if newFocusedField == .grossValue {
                    if let number = Decimal.parseMoney(viewModel.grossValueText),
                        number == 0 {
                        viewModel.grossValueText = ""
                    }
                }
            }

            Picker(
                "\("action.field.recurrence".localized):",
                selection: $viewModel.selectedRecurrence
            ) {
                ForEach(Recurrence.allCases.reversed(), id: \.rawValue) { recurrence in
                    Text(recurrence.rawValue.localized.capitalized)
                        .font(.App.input)
                        .tag(recurrence)
                }
            }
            .font(.App.input)

            PaymentDateFields(
                firstPaymentDate: $viewModel.firstPaymentDate,
                includesLastPayment: $viewModel.includesLastPayment,
                lastPaymentDate: $viewModel.lastPaymentDate,
                recurrence: viewModel.selectedRecurrence,
                lastPaymentError: viewModel.lastPaymentErrorMessage,
                nextPaymentDate: viewModel.nextPaymentDate
            )

            if editingIncome != nil {
                CTAButton(title: "action.button.edit".localized, color: .Palette.incomeAccent) {
                    viewModel.edit { didEdit in
                        if didEdit {
                            dismiss.callAsFunction()
                        }
                    }
                }
                .padding(.vertical, 6)
            } else {
                CTAButton(title: "action.button.submit".localized, color: .Palette.incomeAccent) {
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

    // MARK: Initialization

    init(services: AppServices, editingIncome: Income? = nil) {
        self.editingIncome = editingIncome
        _viewModel = StateObject(wrappedValue: ViewModel(services: services))
    }
}

// MARK: - Previews

struct IncomeActionView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        data.financeData = FinanceData(incomes: [Income](), expenses: [Expense]())
        return data
    }

    static var previews: some View {
        IncomeActionView(services: .preview)
            .environmentObject(envObject)
    }
}
