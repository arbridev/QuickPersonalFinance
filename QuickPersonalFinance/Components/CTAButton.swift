//
//  CTAButton.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 13/4/23.
//

import SwiftUI

struct CTAButton: View {
    var title: String
    var titleColor: Color?
    var color: Color?
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title.uppercased())
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, idealHeight: 40, maxHeight: 60, alignment: .center)
        .background(content: {
            RoundedRectangle(cornerSize: CGSize(width: 16.0, height: 16.0))
                .foregroundColor(color ?? Color.Palette.blue)
        })
        .tint(titleColor ?? Color.white)
        .font(.App.buttonTitle)
    }
}

struct CTAButton_Previews: PreviewProvider {
    static var previews: some View {
        CTAButton(title: "Button") {
            print("touched")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
