//
//  IncomeActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomeActionView: View {
    @EnvironmentObject var mainData: AppData
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: ViewModel = ViewModel()
    @FocusState var isInputActive: Bool

    var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(dismiss: dismiss)
            // MARK: Content
            Spacer()
            VStack {
                Text("Income Create/Edit")
                Form {
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

struct IncomeActionView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeActionView()
    }
}
