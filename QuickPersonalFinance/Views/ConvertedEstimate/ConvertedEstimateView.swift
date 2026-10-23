//
//  ConvertedEstimateView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/5/23.
//

import SwiftUI

struct ConvertedEstimateView: View {
    @EnvironmentObject private var mainData: AppData
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ViewModel

    var recurrence: Recurrence

    var body: some View {
        ZStack {
            VStack {
                // MARK: Top bar
                ModalViewUpperBar(
                    title: "converted.estimate.title",
                    dismiss: dismiss
                )
                Spacer()
            }

            VStack {
                Spacer()

                // MARK: Control
                if !viewModel.isRefreshing {
                    Picker(
                        "converted.estimate.currency",
                        selection: $viewModel.pickerSelectedCurrency
                    ) {
                        ForEach(viewModel.currencyIDs, id: \.self) { currencyID in
                            Text(currencyID)
                                .font(.App.input)
                                .tag(currencyID)
                        }
                    }
                    .padding(.bottom, 4)
                    .font(.App.input)
                    .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.isErrorPresented) {
                        Button("action.button.ok", role: .cancel) {}
                    }
                } else {
                    ProgressView()
                }

                Divider()

                // MARK: Estimate table
                VStack {
                    Divider()
                        .overlay(Color.Palette.dividerPrimary)
                        .padding(.horizontal)

                    EstimateTableView(summary: viewModel.summary)
                }
                Spacer()
            }
            .onAppear {
                viewModel.input(financeData: mainData.financeData, recurrence: recurrence)
            }
        }
    }

    // MARK: Initialization

    init(services: AppServices, recurrence: Recurrence) {
        self.recurrence = recurrence
        _viewModel = StateObject(wrappedValue: ViewModel(services: services))
    }
}

struct ConvertedEstimateView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        let incomes = [
            MockData.income1
        ]

        let expenses = [
            MockData.expense1
        ]

        data.financeData = FinanceData(
            incomes: incomes,
            expenses: expenses
        )
        return data
    }

    static var previews: some View {
        ConvertedEstimateView(services: .preview, recurrence: .year)
            .environmentObject(envObject)
    }
}
