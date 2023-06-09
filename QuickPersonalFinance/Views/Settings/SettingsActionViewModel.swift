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
                } else if !workHoursPerDayText.isEmpty {
                    settings.workHoursPerDay = Double(workHoursPerDayText)!
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
                } else if !workDaysPerWeekText.isEmpty {
                    settings.workDaysPerWeek = Double(workDaysPerWeekText)!
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

        init() {
            settings = Settings()
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
