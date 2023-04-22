//
//  IncomesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomesView: View {
    @EnvironmentObject private var mainData: AppData
    @Environment(\.managedObjectContext) var moc

    @StateObject private var viewModel: ViewModel = ViewModel()
    @State private var isPresentingAction = false

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isPresentingAction = true
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.trailing)
                .sheet(isPresented: $isPresentingAction) {
                    IncomeActionView()
                        .environmentObject(mainData)
                }
            }
            Spacer()
            VStack {
                Text("incomes.title")
                    .asScreenTitle()
                List {
                    ForEach(mainData.financeData.incomes, id: \.hashValue) { income in
                        HStack {
                            Text(income.name)
                            Spacer()
                            Text(String(format: "\(currencyCode) %.2f", income.grossValue))
                        }
                    }
                    .onDelete(perform: { viewModel.deleteItems(at: $0) })
                }
                .font(.App.standard)
            }
            Spacer()
        }
        .onAppear {
            viewModel.input(mainData: mainData, moc: moc)
        }
    }
}

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
