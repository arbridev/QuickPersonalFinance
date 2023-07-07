//
//  SourceRowView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 4/7/23.
//

import SwiftUI

struct SourceRowView: View {
    var source: any Source
    var currencyID: String
    var recurrenceLoc: LocalizedStringKey {
        LocalizedStringKey(source.recurrence?.rawValue ?? Recurrence.year.rawValue)
    }

    var body: some View {
        HStack {
            Text(source.name)
            Spacer()
            VStack(alignment: .trailing) {
                Text(source.grossValue.asCurrency(withID: currencyID))
                Text(recurrenceLoc)
                    .font(.App.info)
            }
        }
        .contentShape(Rectangle())
    }
}

struct SourceRowView_Previews: PreviewProvider {
    static let source = MockData.income1
    static let currencyID = Constant.defaultCurrencyID

    static var previews: some View {
        SourceRowView(source: source, currencyID: currencyID)
            .previewLayout(.fixed(width: 300, height: 80))
    }
}
