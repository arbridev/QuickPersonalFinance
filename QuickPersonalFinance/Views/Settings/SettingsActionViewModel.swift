//
//  SettingsActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 27/4/23.
//

import Foundation

extension SettingsActionView {

    @MainActor class ViewModel: ObservableObject {
        var settings: SettingsService

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

        init() {
            settings = Settings(persistence: UserDefaults.standard)
            workHoursPerDayText = String(settings.workHoursPerDay)
            workDaysPerWeekText = String(settings.workDaysPerWeek)
        }
    }

}
