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

    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            HStack {
                if let icon {
                    icon.foregroundColor(Color(UIColor.systemGray4))
                }
                if let prefix {
                    prefix.foregroundColor(Color(UIColor.systemGreen))
                }
                configuration
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 2)
            }
        }
    }
}
