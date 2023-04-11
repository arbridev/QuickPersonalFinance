//
//  ExpensesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject private var mainData: AppData
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
                List(mainData.financeData.expenses, id: \.hashValue) { expense in
                    HStack {
                        Text(expense.name)
                        Spacer()
                        Text(String(format: "\(currencyCode) %.2f", expense.netValue))
                    }
                }
            }
            Spacer()
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
