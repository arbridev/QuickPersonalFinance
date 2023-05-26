//
//  CalculationService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import Foundation

protocol CalculationService {
    func convert(_ value: Double, from origin: Recurrence, to destination: Recurrence) -> Double
    func totalize(sources: [any Source], to recurrence: Recurrence) -> Double
    func makeBalance(incomes: [Income], expenses: [Expense], basedOn recurrence: Recurrence) -> Double
}

/// Service for calculations
class Calculation: CalculationService {

    // MARK: Properties

    private let settings: SettingsService

    // MARK: Initialization

    init(
        settings: SettingsService = Settings(persistence: UserDefaults.standard)
    ) {
        self.settings = settings
    }

    // MARK: Behavior

    func convert(
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

    func makeBalance(
        incomes: [Income],
        expenses: [Expense],
        basedOn recurrence: Recurrence
    ) -> Double {
        let totalIncome = totalize(sources: incomes, to: recurrence)
        let totalExpense = totalize(sources: expenses, to: recurrence)
        return totalIncome - totalExpense
    }
}
