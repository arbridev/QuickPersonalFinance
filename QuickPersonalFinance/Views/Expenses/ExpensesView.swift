//
//  ExpensesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpensesView: View {

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
                    HapticsService().impactFeedback(style: .light)
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.trailing)
                .sheet(isPresented: $viewModel.isPresentingCreateAction) {
                    ExpenseActionView()
                }
            }
            Spacer()
            VStack {
                if mainData.financeData.expenses.isEmpty {
                    // MARK: Empty content
                    Text("expenses.title")
                        .asScreenTitle()
                    Spacer()
                    EmptyContentView(
                        title: "expenses.empty.title",
                        message: "expenses.empty.message"
                    )
                    Spacer()
                } else {
                    // MARK: List of expenses
                    Text("expenses.title")
                        .asScreenTitle()
                    List {
                        ForEach(mainData.financeData.expenses, id: \.hashValue) { expense in
                            SourceRowView(source: expense, currencyID: viewModel.currencyID)
                                .onTapGesture {
                                    viewModel.selectedItem = expense
                                }
                        }
                        .onDelete(perform: { viewModel.deleteItems(at: $0) })
                    }
                    .font(.App.standard)
                    .sheet(isPresented: $viewModel.isPresentingEditAction) {
                        ExpenseActionView(editingExpense: viewModel.selectedItem!)
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

struct ExpensesView_Previews: PreviewProvider {
    static let expenseLargeTitle = Expense(
        id: MockData.expense2.id,
        name: String(repeating: MockData.expense2.name, count: 8),
        more: MockData.expense2.more,
        grossValue: MockData.expense2.grossValue,
        recurrence: MockData.expense2.recurrence
    )
    static var envObject: AppData {
        let data = AppData()
        let expenses = [
            MockData.expense1,
            expenseLargeTitle
        ]
        data.financeData = FinanceData(incomes: [Income](), expenses: expenses)
        return data
    }
    
    static var previews: some View {
        ExpensesView()
            .environmentObject(envObject)
    }
}
