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

    @StateObject private var viewModel: ViewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(dismiss: dismiss)
            Spacer()
            // MARK: Content
            VStack {
                Text("Expense Create/Edit")

                Form {
                    CustomTextField(
                        text: $viewModel.nameText,
                        errorMessage: $viewModel.nameTextErrorMessage,
                        placeholder: "Name",
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .padding(.vertical, 4)

                    CustomTextField(
                        text: $viewModel.moreText,
                        errorMessage: Binding.constant(nil),
                        placeholder: "More",
                        prefix: nil,
                        keyboardType: .alphabet
                    )
                    .padding(.vertical, 4)

                    CustomTextField(
                        text: $viewModel.grossValueText,
                        errorMessage: $viewModel.grossValueErrorMessage,
                        placeholder: "Gross value",
                        prefix: currencyCode,
                        keyboardType: .decimalPad
                    ) { isStarting in
                        if let number = Double(viewModel.grossValueText), isStarting && number == 0.0 {
                            viewModel.grossValueText = ""
                        }
                    }
                    .padding(.vertical, 4)

                    Picker("Recurrence", selection: $viewModel.selectedRecurrence) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.capitalized).tag(recurrence)
                        }
                    }

                    Button {
                        viewModel.submit { didSubmit in
                            if didSubmit {
                                dismiss.callAsFunction()
                            }
                        }
                    } label: {
                        Text("Submit")
                            .padding(6)
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.mainData = mainData
        }
    }
}

struct ExpenseActionView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseActionView()
    }
}
