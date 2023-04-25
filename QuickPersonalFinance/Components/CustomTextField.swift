//
//  CustomTextField.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 6/4/23.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    @Binding var errorMessage: String?
    var placeholder: String
    var prefix: String?
    var prefixColor: Color?
    var keyboardType: UIKeyboardType

    var body: some View {
        VStack {
            TextField(text: $text) {
                Text(placeholder)
                    .foregroundColor(Color.Palette.textFieldOutline)
            }
            .keyboardType(keyboardType)
            .textFieldStyle(
                OutlinedTextFieldStyle(
                    prefix: prefix == nil ? nil : Text(prefix!),
                    prefixColor: prefixColor
                )
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.App.error)
                    .foregroundColor(.pink)
            }
        }
    }
}
