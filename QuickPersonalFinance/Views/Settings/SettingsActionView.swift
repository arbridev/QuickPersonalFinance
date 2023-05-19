//
//  SettingsActionView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 27/4/23.
//

import SwiftUI

struct SettingsActionView: View {
    enum Field: Hashable {
        case workHoursPerDayText, workDaysPerWeekText
    }
    
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = ViewModel()
    @FocusState private var focusedField: Field?

    var body: some View {
        // MARK: Upper bar
        ModalViewUpperBar(
            title: "settings.action.title".localized,
            dismiss: dismiss
        )
        // MARK: Content
        Spacer()
        VStack {
            Form {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("settings.action.field.work.hours.day".localized)
                            .font(.App.input)
                            .padding(.trailing, 4)

                        CustomTextField(
                            text: $viewModel.workHoursPerDayText,
                            errorMessage: Binding.constant(nil),
                            placeholder: "settings.action.field.work.hours.day".localized,
                            prefix: nil,
                            keyboardType: .alphabet
                        )
                        .padding(.top, 4)
                        .listRowSeparator(.hidden)
                        .focused($focusedField, equals: .workHoursPerDayText)
                    }
                    Text("settings.action.field.suggestion.average".localized)
                        .font(.App.info)
                }

                VStack(alignment: .trailing) {
                    HStack {
                        Text("settings.action.field.work.days.week".localized)
                            .font(.App.input)
                            .padding(.trailing, 4)

                        CustomTextField(
                            text: $viewModel.workDaysPerWeekText,
                            errorMessage: Binding.constant(nil),
                            placeholder: "settings.action.field.work.days.week".localized,
                            prefix: nil,
                            keyboardType: .alphabet
                        )
                        .listRowSeparator(.hidden)
                        .padding(.top, 4)
                        .focused($focusedField, equals: .workDaysPerWeekText)
                    }
                    Text("settings.action.field.suggestion.average".localized)
                        .font(.App.info)
                }

                Section {
                    Picker(
                        "\("settings.action.field.currency".localized):",
                        selection: $viewModel.selectedCurrency
                    ) {
                        ForEach(Locale.Currency.isoCurrencies, id: \.identifier) { currency in
                            Text(currency.identifier)
                                .font(.App.input)
                                .tag(currency.identifier)
                        }
                    }
                    .padding(.bottom, 4)
                    .font(.App.input)

                    Button {
                        viewModel.resetToLocalCurrency()
                    } label: {
                        HStack(alignment: .center) {
                            Text("settings.action.button.reset")
                                .font(.App.input)
                        }
                    }
                }
            }
        }
    }
}

struct SettingsActionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsActionView()
    }
}
