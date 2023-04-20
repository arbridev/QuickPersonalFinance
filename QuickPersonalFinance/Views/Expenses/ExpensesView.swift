//
//  ExpensesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpensesView: View {
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
                    ExpenseActionView()
                }
            }
            Spacer()
            VStack {
                Text("Expenses")
                    .asScreenTitle()
                List {
                    ForEach(mainData.financeData.expenses, id: \.hashValue) { expense in
                        HStack {
                            Text(expense.name)
                            Spacer()
                            Text(String(format: "\(currencyCode) %.2f", expense.grossValue))
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

struct ExpensesView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        let expenses = [
            MockData.expense2
        ]
        data.financeData = FinanceData(incomes: [Income](), expenses: expenses)
        return data
    }
    
    static var previews: some View {
        ExpensesView()
            .environmentObject(envObject)
    }
}
