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
    var prefix: String
    var keyboardType: UIKeyboardType
    @FocusState var isFocused: Bool
    var onEditingChanged: (Bool) -> Void

    var body: some View {
        VStack {
            TextField(placeholder, text: $text, onEditingChanged: onEditingChanged)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .textFieldStyle(OutlinedTextFieldStyle(prefix: Text(prefix)))

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
