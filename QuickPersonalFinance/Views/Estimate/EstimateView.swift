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
                                .tag(recurrence)
                        }
                    }
                    .tint(Color.Palette.blue2)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)

                HStack {
                    Text("Income:")
                        .font(.system(size: 16))
                    Spacer()
                    Text("\(viewModel.incomeTotal.asCurrency)")
                        .font(.system(size: 16))
                        .underline(true, color: .Palette.green)
                }
                .padding(.top)
                .padding(.horizontal)

                HStack {
                    Text("Expense:")
                        .font(.system(size: 16))
                    Spacer()
                    Text("\(viewModel.expenseTotal.asCurrency)")
                        .font(.system(size: 16))
                        .underline(true, color: .Palette.red)
                }
                .padding(.top)
                .padding(.horizontal)

                Divider()
                    .overlay(Color.Palette.gray0)
                    .padding(.top)
                    .padding(.horizontal)

                HStack {
                    Text("Total:")
                        .font(.system(size: 20))
                    Spacer()
                    Text("\(viewModel.balance.asCurrency)")
                        .font(.system(size: 20))
                        .underline(true, color: .Palette.blue)
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

            Spacer()
        }
    }

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .red
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
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
