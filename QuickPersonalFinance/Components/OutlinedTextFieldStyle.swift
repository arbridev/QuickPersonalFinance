//
//  OutlinedTextFieldStyle.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 21/3/23.
//

import SwiftUI

/// Source: https://medium.com/@ricardomongza/create-custom-textfield-styles-in-swiftui-b484b7ba31bf
struct OutlinedTextFieldStyle: TextFieldStyle {
    @State var icon: Image?
    @State var prefix: Text?
    var iconColor: Color?
    var prefixColor: Color?

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            HStack {
                if let icon {
                    icon.foregroundColor(iconColor ?? .Palette.iconPrimary)
                }
                if let prefix {
                    prefix.foregroundColor(prefixColor ?? .Palette.estimateAccent)
                }
                configuration
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.Palette.textFieldOutline, lineWidth: 2)
            }
            .font(.App.input)
        }
    }
}
