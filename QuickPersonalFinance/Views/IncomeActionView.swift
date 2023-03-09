//
//  IncomeActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct IncomeActionView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .padding(.top)
                .padding(.trailing)
            }
            Spacer()
            VStack {
                Text("Income Create/Edit")
            }
            Spacer()
        }
    }
}

struct IncomeActionView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeActionView()
    }
}
