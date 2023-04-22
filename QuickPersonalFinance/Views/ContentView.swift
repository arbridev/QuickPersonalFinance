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
    @StateObject private var mainData = AppData()
    @Environment(\.managedObjectContext) var moc

    @StateObject private var viewModel = ViewModel()
    @State private var selectedTab = 0

    private var tabTint: Color {
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
                        Label(
                            "incomes.title".localized,
                            systemImage: "plus.circle"
                        )
                    }
                    .tag(0)
                    .font(.app(size: 20))
                ExpensesView()
                    .tabItem {
                        Label(
                            "expenses.title".localized,
                            systemImage: "minus.circle"
                        )
                    }
                    .tag(1)
                    .font(.app(size: 20))
                EstimateView()
                    .tabItem {
                        Label(
                            "estimate.title".localized,
                            systemImage: "plus.forwardslash.minus"
                        )
                    }
                    .tag(2)
                    .font(.app(size: 20))
            }
            .tint(tabTint)
            .font(.app(size: 12))
        }
        .environmentObject(mainData)
        .onAppear {
            viewModel.input(mainData: mainData, moc: moc)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
