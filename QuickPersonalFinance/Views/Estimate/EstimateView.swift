//
//  EstimateView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct EstimateView: View {
    @EnvironmentObject private var mainData: AppData
    @StateObject private var viewModel = ViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack {
            HStack {
                Text("Time span:")
                Picker("Recurrence", selection: $viewModel.selectedRecurrence) {
                    ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                        Text(recurrence.rawValue.capitalized).tag(recurrence)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)

            Text("Estimate")
                .font(.title2)

            HStack {
                Text("Income:")
                    .font(.caption)
                Spacer()
                Text("\(viewModel.incomeTotal.asCurrency)")
                    .font(.caption)
            }
            .padding(.top)
            .padding(.horizontal)

            HStack {
                Text("Expense:")
                    .font(.caption)
                Spacer()
                Text("\(viewModel.expenseTotal.asCurrency)")
                    .font(.caption)
            }
            .padding(.top)
            .padding(.horizontal)

            Divider()
                .overlay(.gray)
                .padding(.top)
                .padding(.horizontal)

            HStack {
                Text("Total:")
                Spacer()
                Text("\(viewModel.balance.asCurrency)")
                    .font(.subheadline)
            }
            .padding(.top)
            .padding(.horizontal)

            HStack {
                Spacer()
                Text("\(currencyCode) per \(viewModel.selectedRecurrence.rawValue)")
                    .font(.caption)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            viewModel.mainData = mainData
            viewModel.update()
        }
    }
}

struct EstimateView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        let incomes = [
            Income(
                name: "income 1",
                more: nil,
                netValue: 20.0,
                recurrence: .hour
            )
        ]

        data.financeData = FinanceData(incomes: incomes, expenses: [Expense]())
        return data
    }
    
    static var previews: some View {
        EstimateView()
            .environmentObject(envObject)
    }
}
