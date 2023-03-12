//
//  ContentView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

class AppData: ObservableObject {
    @Published var financeData = FinanceData(
        incomes: [Income](),
        expenses: [Expense](),
        frequency: .day
    )
}

struct ContentView: View {
    @StateObject var mainData = AppData()

    var body: some View {
        TabView {
            IncomesView()
                .tabItem {
                    Label("Incomes", systemImage: "plus.circle")
                }
            ExpensesView()
                .tabItem {
                    Label("Expenses", systemImage: "minus.circle")
                }
            EstimateView()
                .tabItem {
                    Label("Estimate", systemImage: "plus.forwardslash.minus")
                }
        }
        .environmentObject(mainData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
