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

    let barChartColors: [Color] = [.Palette.incomeTable, .Palette.expenseTable]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    viewModel.isPresentingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .padding(.trailing)
                .sheet(isPresented: $viewModel.isPresentingSettings) {
                    SettingsActionView()
                }
            }

            Text("estimate.title")
                .asScreenTitle()

            Spacer()

            VStack {
                HStack {
                    Text("\("estimate.action.time.span".localized):")
                    Picker(
                        "action.field.recurrence".localized,
                        selection: $viewModel.selectedRecurrence
                    ) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.localized.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .tint(Color.Palette.estimateAccentSecondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                .font(.App.input)

                Divider()
                    .overlay(Color.Palette.dividerPrimary)
                    .padding(.horizontal)

                HStack {
                    Text("estimate.table.income")
                    Spacer()
                    Text("\(viewModel.incomeTotal.asCurrency(withID: viewModel.currencyID))")
                        .underline(true, color: .Palette.incomeAccent)
                }
                .padding(.top)
                .padding(.horizontal)
                .font(.app(size: 18))

                HStack {
                    Text("estimate.table.expense")
                    Spacer()
                    Text("\(viewModel.expenseTotal.asCurrency(withID: viewModel.currencyID))")
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
                    Text("\(viewModel.balance.asCurrency(withID: viewModel.currencyID))")
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

                Menu {
                    ShareLink(item: viewModel.shareMessage) {
                        Label("share.summary", systemImage: "square.and.arrow.up")
                    }
                    ExportPDFView(recurrence: viewModel.selectedRecurrence)
                        .environmentObject(mainData)
                } label: {
                    Label("estimate.button.share", systemImage: "square.and.arrow.up")
                }

                Divider()
                    .overlay(Color.Palette.dividerSecondary)
                    .padding(.vertical)

                Chart {
                    ForEach(viewModel.barChartData, id: \.title) { barValue in
                        BarMark(
                            x: .value("estimate.chart.source".localized, barValue.title),
                            y: .value("estimate.table.total".localized, barValue.total)
                        )
                        .foregroundStyle(by: .value("estimate.chart.source".localized, barValue.title))
                    }
                }
                .chartForegroundStyleScale(
                    domain: [
                        "estimate.table.income".localized,
                        "estimate.table.expense".localized],
                    range: barChartColors
                )
            }
            .padding()
            .onAppear {
                viewModel.input(mainData: mainData)
                viewModel.update()
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
//            .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
    }
}
