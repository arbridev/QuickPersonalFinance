//
//  SettingsActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 27/4/23.
//

import Foundation

extension SettingsActionView {

    @MainActor class ViewModel: ObservableObject {
        @Published var workHoursPerDayText: String {
            didSet {
                let preemptiveValidation = DoubleValidation(value: workHoursPerDayText)
                if !preemptiveValidation.isValid {
                    workHoursPerDayText = oldValue
                } else if !workHoursPerDayText.isEmpty {
                    settings.workHoursPerDay = Double(workHoursPerDayText)!
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
            }
        }
        
        @Published var selectedCurrency: String {
            didSet {
                settings.currencyID = selectedCurrency
            }
        }

        private var settings: SettingsService

        init() {
            settings = Settings()
            workHoursPerDayText = String(settings.workHoursPerDay)
            workDaysPerWeekText = String(settings.workDaysPerWeek)
            selectedCurrency = settings.currencyID
        }

        func resetToLocalCurrency() {
            selectedCurrency = Locale.current.currency?.identifier ?? Constant.defaultCurrencyID
        }
    }

}
