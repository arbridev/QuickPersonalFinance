//
//  ExpensesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpensesView: View {
    @State private var isPresentingAction = false

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
                }
            }
            Spacer()
            VStack {
                Text("Expenses")
            }
            Spacer()
        }
    }
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesView()
    }
}
