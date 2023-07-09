//
//  ModalViewUpperBar.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/3/23.
//

import SwiftUI

struct ModalViewUpperBar: View {
    var title: String
    var dismiss: DismissAction?

    var body: some View {
        VStack {
            if let dismiss {
                HStack {
                    Spacer()
                    Button {
                        HapticsService().impactFeedback(style: .light)
                        dismiss.callAsFunction()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding(.top)
                    .padding(.trailing)
                    .accessibilityIdentifier("modal_close")
                }
                .frame(maxHeight: 50)
            }

            Text(LocalizedStringKey(title))
                .asScreenTitle()
        }
    }
}

struct ModalViewUpperBar_Previews: PreviewProvider {
    static var previews: some View {
        ModalViewUpperBar(title: "Modal title")
            .previewLayout(.sizeThatFits)
    }
}
