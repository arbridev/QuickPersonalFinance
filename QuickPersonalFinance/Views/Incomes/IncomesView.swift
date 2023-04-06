//
//  IncomesView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomesView: View {
    @EnvironmentObject var mainData: AppData
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
                        .environmentObject(mainData)
                }
            }
            Spacer()
            VStack {
                Text("Incomes")
            }
            Spacer()
        }
    }
}

struct IncomesView_Previews: PreviewProvider {
    static var previews: some View {
        IncomesView()
    }
}
