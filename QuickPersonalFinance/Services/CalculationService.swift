//
//  CalculationService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import Foundation

protocol CalculationService {
    var incomes: [Income] { get set }
    var expenses: [Expense] { get set }
    func totalize(sources: [any Source], to recurrence: Recurrence) -> Double
    func monthlyBalance() -> Double
}

/// Service for calculations
class Calculation: CalculationService {
    private let settings: SettingsService
    var incomes: [Income]
    var expenses: [Expense]

    init(
        incomes: [Income],
        expenses: [Expense],
        settings: SettingsService = Settings(persistence: UserDefaults.standard)
    ) {
        self.incomes = incomes
        self.expenses = expenses
        self.settings = settings
    }

    private func convert(
        _ value: Double,
        from origin: Recurrence,
        to destination: Recurrence
    ) -> Double {
        guard origin != destination else {
            return value
        }
        let isForward = origin < destination // advances from top to bottom
        guard let currentIndex = Recurrence.allCases.firstIndex(where: { $0 == origin }) else {
            return value
        }
        let offset = isForward ? currentIndex + 1 : currentIndex - 1
        guard offset >= 0 && offset < Recurrence.allCases.count else {
            return value
        }
        let next = Recurrence.allCases[offset]
        var factor: Double!
        if isForward {
            let forwardConversionFactor: [Recurrence: Double] = [
                .hour: 1,
                .day: settings.workHoursPerDay,
                .week: settings.workDaysPerWeek,
                .month: Constant.weeksPerMonthCount,
                .year: Constant.monthsPerYearCount
            ]
            factor = forwardConversionFactor[next]
        } else {
            let backwardConversionFactor: [Recurrence: Double] = [
                .hour: settings.workHoursPerDay,
                .day: settings.workDaysPerWeek,
                .week: Constant.weeksPerMonthCount,
                .month: Constant.monthsPerYearCount,
                .year: 1
            ]
            factor = backwardConversionFactor[next]
        }

        let newValue = isForward ? value * factor : value / factor
        return convert(newValue, from: next, to: destination)
    }

    func totalize(sources: [any Source], to recurrence: Recurrence) -> Double {
        sources.map { source in
            source.recurrence != nil ?
            convert(source.grossValue, from: source.recurrence!, to: recurrence) :
            source.grossValue
        }
        .reduce(0, +)
    }

    func monthlyBalance() -> Double {
        totalize(sources: incomes, to: .month) - totalize(sources: expenses, to: .month)
    }
}
