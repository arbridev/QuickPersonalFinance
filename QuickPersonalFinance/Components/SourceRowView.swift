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

    private var nextPaymentText: String? {
        guard let recurrence = source.recurrence else {
            return nil
        }
        if let next = source.nextPaymentDate() {
            let label = PaymentSchedule.format(next, recurrence: recurrence)
            return "\("action.field.next.payment".localized): \(label)"
        }
        guard source.firstPaymentDate != nil else {
            return nil
        }
        return "action.field.next.payment.ended".localized
    }

    var body: some View {
        HStack {
            Text(source.name)
            Spacer()
            VStack(alignment: .trailing) {
                Text(source.grossValue.asCurrency(withID: currencyID))
                Text(recurrenceLoc)
                    .font(.App.info)
                if let nextPayment = nextPaymentText {
                    Text(nextPayment)
                        .font(.App.info)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

/// Plain list-row button whose tap target is the whole cell.
/// The default plain style inside a `List` only hits the title text.
struct FullWidthRowButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                configuration.trigger()
            }
    }
}

struct PaymentDateFields: View {
    @Binding var firstPaymentDate: Date
    @Binding var includesLastPayment: Bool
    @Binding var lastPaymentDate: Date
    var recurrence: Recurrence
    var lastPaymentError: String?
    var nextPaymentDate: Date?

    private var components: DatePicker<Text>.Components {
        recurrence == .hour ? [.date, .hourAndMinute] : [.date]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DatePicker(
                "action.field.first.payment",
                selection: $firstPaymentDate,
                displayedComponents: components
            )
            Toggle("action.field.has.last.payment", isOn: $includesLastPayment)
            if includesLastPayment {
                DatePicker(
                    "action.field.last.payment",
                    selection: $lastPaymentDate,
                    displayedComponents: components
                )
            }
            status
        }
        .font(.App.input)
        .padding(.bottom, 4)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private var status: some View {
        if includesLastPayment, let lastPaymentError {
            Text(lastPaymentError)
                .font(.App.error)
                .foregroundColor(.pink)
        } else if let nextPaymentDate {
            HStack {
                Text("action.field.next.payment")
                Spacer()
                Text(PaymentSchedule.format(nextPaymentDate, recurrence: recurrence))
            }
            .font(.App.info)
        } else if includesLastPayment {
            Text("action.field.next.payment.ended")
                .font(.App.info)
        }
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
