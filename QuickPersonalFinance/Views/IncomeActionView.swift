//
//  IncomeActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomeActionView: View {
    @EnvironmentObject private var mainData: AppData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var moc

    @StateObject private var viewModel: ViewModel = ViewModel()

    var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(title: "income.action.title".localized, dismiss: dismiss)
            // MARK: Content
            Spacer()
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
                        prefixColor: .Palette.green,
                        keyboardType: .decimalPad
                    ) { isStarting in
                        if let number = Double(viewModel.grossValueText),
                            isStarting && number == 0.0
                        {
                            viewModel.grossValueText = ""
                        }
                    }
                    .listRowSeparator(.hidden)

                    Picker(
                        "\("action.field.recurrence".localized):",
                        selection: $viewModel.selectedRecurrence
                    ) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.localized.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .padding(.bottom, 4)
                    .font(.App.input)

                    CTAButton(title: "action.button.submit".localized, color: .Palette.green) {
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

struct IncomeActionView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        data.financeData = FinanceData(incomes: [Income](), expenses: [Expense]())
        return data
    }

    static var previews: some View {
        IncomeActionView()
            .environmentObject(envObject)
    }
}
