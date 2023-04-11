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
        expenses: [Expense]()
    )
}

struct ContentView: View {
    @StateObject var mainData = AppData()
    @State private var selectedTab = 0 {
        didSet {
            print("selectedtab \(selectedTab)")
        }
    }

    var tabTint: Color {
        switch selectedTab {
            case 0:
                return Color.Palette.green
            case 1:
                return Color.Palette.red
            case 2:
                return Color.Palette.blue
            default:
                return Color.Palette.blue
        }
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                IncomesView()
                    .tabItem {
                        Label("Incomes", systemImage: "plus.circle")
                    }
                    .tag(0)
                ExpensesView()
                    .tabItem {
                        Label("Expenses", systemImage: "minus.circle")
                    }
                    .tag(1)
                EstimateView()
                    .tabItem {
                        Label("Estimate", systemImage: "plus.forwardslash.minus")
                    }
                    .tag(2)
            }
            .tint(tabTint)
        }
        .environmentObject(mainData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
