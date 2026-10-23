//
//  IncomesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomesView: View {

    // MARK: Properties

    @EnvironmentObject private var mainData: AppData

    @StateObject private var viewModel: ViewModel

    private let services: AppServices

    var body: some View {
        VStack {
            // MARK: Top bar
            HStack {
                Spacer()
                Button {
                    viewModel.isPresentingCreateAction = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("accessibility.add")
                .padding(.trailing)
                .sheet(isPresented: $viewModel.isPresentingCreateAction) {
                    IncomeActionView(services: services)
                        .environmentObject(mainData)
                }
            }
            Spacer()
            VStack {
                if mainData.financeData.incomes.isEmpty {
                    // MARK: Empty content
                    Text("incomes.title")
                        .asScreenTitle()
                    Spacer()
                    EmptyContentView(
                        title: "incomes.empty.title",
                        message: "incomes.empty.message"
                    )
                    Spacer()
                } else {
                    // MARK: List of incomes
                    Text("incomes.title")
                        .asScreenTitle()
                    List {
                        ForEach(mainData.financeData.incomes) { income in
                            Button {
                                viewModel.selectedItem = income
                                HapticsService().impactFeedback(style: .light)
                            } label: {
                                SourceRowView(source: income, currencyID: viewModel.currencyID)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: { viewModel.deleteItems(at: $0) })
                    }
                    .font(.App.standard)
                    .sheet(item: $viewModel.selectedItem) { income in
                        IncomeActionView(services: services, editingIncome: income)
                            .environmentObject(mainData)
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.input(mainData: mainData)
        }
    }

    // MARK: Initialization

    init(services: AppServices) {
        self.services = services
        _viewModel = StateObject(wrappedValue: ViewModel(services: services))
    }
}

// MARK: - Previews

struct IncomesView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        let incomes = [
            MockData.income1
        ]
        data.financeData = FinanceData(incomes: incomes, expenses: [Expense]())
        return data
    }

    static var previews: some View {
        IncomesView(services: .preview)
            .environmentObject(envObject)
    }
}
