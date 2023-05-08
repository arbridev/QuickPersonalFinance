//
//  EmptyContentView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 8/5/23.
//

import SwiftUI

struct EmptyContentView: View {
    var title: String?
    var message: String

    var body: some View {
        VStack {
            if let title {
                Text(LocalizedStringKey(title))
                    .font(.title(size: 26))
                    .padding(.bottom)
                    .padding(.horizontal, 100)
                    .multilineTextAlignment(.center)
            }
            
            Text(LocalizedStringKey(message))
                .font(.app(size: 20))
                .padding(.horizontal, 50)
                .multilineTextAlignment(.center)
        }
    }
}

struct EmptyContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyContentView(
            title: "This is the Title",
            message: """
                This is a message that can be large or short
                but I want to make it a bit larger to try the UI.
                """
        )
    }
}
