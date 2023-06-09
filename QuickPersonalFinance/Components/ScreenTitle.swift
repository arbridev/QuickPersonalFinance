//
//  ScreenTitle.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 13/4/23.
//

import SwiftUI

struct ScreenTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.App.screenTitle)
    }
}

extension View {
    func asScreenTitle() -> some View {
        modifier(ScreenTitle())
    }
}
