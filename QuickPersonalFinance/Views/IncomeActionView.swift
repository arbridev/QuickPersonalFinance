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

    @StateObject private var viewModel: ViewModel = ViewModel()

    var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(title: "Income Create/Edit", dismiss: dismiss)
            // MARK: Content
            Spacer()
            VStack {
                Form {
                    CustomTextField(
                        text: $viewModel.nameText,
                        errorMessage: $viewModel.nameTextErrorMessage,
                        placeholder: "Name",
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .padding(.top, 4)
                    .listRowSeparator(.hidden)

                    CustomTextField(
                        text: $viewModel.moreText,
                        errorMessage: Binding.constant(nil),
                        placeholder: "More",
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .listRowSeparator(.hidden)

                    CustomTextField(
                        text: $viewModel.grossValueText,
                        errorMessage: $viewModel.grossValueErrorMessage,
                        placeholder: "Gross value",
                        prefix: currencyCode,
                        prefixColor: .Palette.green,
                        keyboardType: .decimalPad
                    ) { isStarting in
                        if let number = Double(viewModel.grossValueText), isStarting && number == 0.0 {
                            viewModel.grossValueText = ""
                        }
                    }
                    .listRowSeparator(.hidden)

                    Picker("Recurrence:", selection: $viewModel.selectedRecurrence) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .padding(.bottom, 4)
                    .font(.App.input)

                    CTAButton(title: "Submit", color: .Palette.green) {
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
            viewModel.mainData = mainData
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
