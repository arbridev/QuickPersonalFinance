//
//  ExpenseActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct ExpenseActionView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // MARK: Upper bar
            ModalViewUpperBar(dismiss: dismiss)
            Spacer()
            // MARK: Content
            VStack {
                Text("Expense Create/Edit")
            }
            Spacer()
        }
    }
}

struct ExpenseActionView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseActionView()
    }
}
