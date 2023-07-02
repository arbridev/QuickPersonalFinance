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
    @Environment(\.managedObjectContext) var moc
    @StateObject private var viewModel = ViewModel()

    var recurrence: Recurrence
    
    var body: some View {
        VStack {
            // MARK: Top bar
            ModalViewUpperBar(
                title: "converted.estimate.title",
                dismiss: dismiss
            )
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
                
                HStack {
                    Text("estimate.table.income")
                    Spacer()
                    Text("\(viewModel.incomeTotal.asCurrency(withID: viewModel.selectedCurrency))")
                        .underline(true, color: .Palette.incomeAccent)
                }
                .padding(.top)
                .padding(.horizontal)
                .font(.app(size: 18))
                
                HStack {
                    Text("estimate.table.expense")
                    Spacer()
                    Text("\(viewModel.expenseTotal.asCurrency(withID: viewModel.selectedCurrency))")
                        .underline(true, color: .Palette.expenseAccent)
                }
                .padding(.top, 6)
                .padding(.horizontal)
                .font(.app(size: 18))
                
                Divider()
                    .overlay(Color.Palette.dividerSecondary)
                    .padding(.top)
                    .padding(.horizontal)
                
                HStack {
                    Text("estimate.table.total")
                    Spacer()
                    Text("\(viewModel.balance.asCurrency(withID: viewModel.selectedCurrency))")
                        .underline(true, color: .Palette.estimateAccent)
                }
                .padding(.top)
                .padding(.horizontal)
                .font(.app(size: 20))
                
                HStack {
                    Spacer()
                    Text(viewModel.balanceInfoMessage)
                        .font(.App.info)
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .onAppear {
            viewModel.input(
                financeData: mainData.financeData,
                recurrence: recurrence,
                moc: moc
            )
        }
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
        ConvertedEstimateView(recurrence: .year)
            .environmentObject(envObject)
    }
}
