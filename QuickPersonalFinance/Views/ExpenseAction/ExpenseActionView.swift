//
//  ExpenseActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpenseActionView: View {
    @EnvironmentObject private var mainData: AppData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var moc

    @StateObject private var viewModel: ViewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(title: "expense.action.title".localized, dismiss: dismiss)
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

                    CustomTextField(
                        text: $viewModel.moreText,
                        errorMessage: Binding.constant(nil),
                        placeholder: "action.field.more".localized,
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .listRowSeparator(.hidden)

                    CustomTextField(
                        text: $viewModel.grossValueText,
                        errorMessage: $viewModel.grossValueErrorMessage,
                        placeholder: "action.field.gross.value".localized,
                        prefix: currencyCode,
                        prefixColor: .Palette.red,
                        keyboardType: .decimalPad
                    ) { isStarting in
                        if let number = Double(viewModel.grossValueText), isStarting && number == 0.0 {
                            viewModel.grossValueText = ""
                        }
                    }
                    .listRowSeparator(.hidden)

                    Picker("\("action.field.recurrence".localized):", selection: $viewModel.selectedRecurrence) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .padding(.bottom, 4)
                    .font(.App.input)

                    CTAButton(title: "action.button.submit".localized, color: .Palette.red) {
                        viewModel.submit { didSubmit in
                            if didSubmit {
                                dismiss.callAsFunction()
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.input(mainData: mainData, moc: moc)
        }
    }
}

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
