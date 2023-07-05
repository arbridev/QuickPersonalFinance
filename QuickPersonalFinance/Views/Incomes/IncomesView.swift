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
    @Environment(\.managedObjectContext) var moc

    @StateObject private var viewModel = ViewModel()

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
                .padding(.trailing)
                .sheet(isPresented: $viewModel.isPresentingCreateAction) {
                    IncomeActionView()
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
                        ForEach(mainData.financeData.incomes, id: \.hashValue) { income in
                            SourceRowView(source: income, currencyID: viewModel.currencyID)
                                .onTapGesture {
                                    viewModel.selectedItem = income
                                }
                        }
                        .onDelete(perform: { viewModel.deleteItems(at: $0) })
                    }
                    .font(.App.standard)
                    .sheet(isPresented: $viewModel.isPresentingEditAction) {
                        IncomeActionView(editingIncome: viewModel.selectedItem!)
                            .environmentObject(mainData)
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.input(mainData: mainData, moc: moc)
        }
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
        IncomesView()
            .environmentObject(envObject)
    }
}
