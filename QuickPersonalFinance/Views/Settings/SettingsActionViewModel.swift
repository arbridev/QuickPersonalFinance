//
//  SettingsActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 27/4/23.
//

import Foundation

extension SettingsActionView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var workHoursPerDayText: String {
            didSet {
                let preemptiveValidation = DoubleValidation(value: workHoursPerDayText)
                if !preemptiveValidation.isValid {
                    workHoursPerDayText = oldValue
                } else if let value = Double(workHoursPerDayText) {
                    settings.workHoursPerDay = value
                }
                if workHoursPerDayText.count > Constant.maxLengthWorkHoursPerDayField {
                    workHoursPerDayText = oldValue
                }
            }
        }
        @Published var workDaysPerWeekText: String {
            didSet {
                let preemptiveValidation = DoubleValidation(value: workDaysPerWeekText)
                if !preemptiveValidation.isValid {
                    workDaysPerWeekText = oldValue
                } else if let value = Double(workDaysPerWeekText) {
                    settings.workDaysPerWeek = value
                }
                if workDaysPerWeekText.count > Constant.maxLengthWorkDaysPerWeekField {
                    workDaysPerWeekText = oldValue
                }
            }
        }
        @Published var selectedCurrency: String {
            didSet {
                settings.currencyID = selectedCurrency
                HapticsService().selectionFeedback()
            }
        }
        private var settings: SettingsService

        // MARK: Initialization

        init(settings: SettingsService) {
            self.settings = settings
            workHoursPerDayText = String(settings.workHoursPerDay)
            workDaysPerWeekText = String(settings.workDaysPerWeek)
            selectedCurrency = settings.currencyID
        }

        // MARK: Behavior

        func resetToLocalCurrency() {
            selectedCurrency = Locale.current.currency?.identifier ?? Constant.defaultCurrencyID
            HapticsService().selectionFeedback()
        }
    }

}
