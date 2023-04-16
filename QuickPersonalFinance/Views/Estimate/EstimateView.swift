//
//  EstimateView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI
import Charts

struct EstimateView: View {
    @EnvironmentObject private var mainData: AppData
    @StateObject private var viewModel = ViewModel()

    let barChartColors: [Color] = [.Palette.green, .Palette.red]

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack {
            Text("Estimate")
                .asScreenTitle()
                .padding()

            Spacer()

            VStack {
                HStack {
                    Text("Time span:")
                    Picker("Recurrence", selection: $viewModel.selectedRecurrence) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .tint(Color.Palette.blue2)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                .font(.App.input)

                Divider()
                    .overlay(Color.Palette.gray1)
                    .padding(.horizontal)

                HStack {
                    Text("Income")
                    Spacer()
                    Text("\(viewModel.incomeTotal.asCurrency)")
                        .underline(true, color: .Palette.green)
                }
                .padding(.top)
                .padding(.horizontal)
                .font(.app(size: 18))

                HStack {
                    Text("Expense")
                    Spacer()
                    Text("\(viewModel.expenseTotal.asCurrency)")
                        .underline(true, color: .Palette.red)
                }
                .padding(.top, 6)
                .padding(.horizontal)
                .font(.app(size: 18))

                Divider()
                    .overlay(Color.Palette.gray0)
                    .padding(.top)
                    .padding(.horizontal)

                HStack {
                    Text("Total")
                    Spacer()
                    Text("\(viewModel.balance.asCurrency)")
                        .underline(true, color: .Palette.blue)
                }
                .padding(.top)
                .padding(.horizontal)
                .font(.app(size: 20))

                HStack {
                    Spacer()
                    Text("\(currencyCode) per \(viewModel.selectedRecurrence.rawValue)")
                        .font(.App.info)
                }
                .padding(.horizontal)

                Divider()
                    .overlay(Color.Palette.gray0)
                    .padding(.vertical)

                Chart {
                    ForEach(viewModel.barChartData, id: \.title) { barValue in
                        BarMark(
                            x: .value("Source", barValue.title),
                            y: .value("Total", barValue.total)
                        )
                        .foregroundStyle(by: .value("Source", barValue.title))
                    }
                }
                .chartForegroundStyleScale(domain: ["Income", "Expense"], range: barChartColors)
            }
            .padding()
            .onAppear {
                viewModel.mainData = mainData
                viewModel.update()
                viewModel.createChartData()
            }

            Spacer()
        }
    }
}

struct EstimateView_Previews: PreviewProvider {
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
        EstimateView()
            .environmentObject(envObject)
    }
}
