//
//  ModalViewUpperBar.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/3/23.
//

import SwiftUI

struct ModalViewUpperBar: View {
    var dismiss: DismissAction?

    var body: some View {
        HStack {
            Spacer()
            Button {
                dismiss?.callAsFunction()
            } label: {
                Image(systemName: "xmark")
            }
            .padding(.top)
            .padding(.trailing)
        }
        .frame(maxHeight: 50)
    }
}

struct ModalViewUpperBar_Previews: PreviewProvider {
    static var previews: some View {
        ModalViewUpperBar()
    }
}
