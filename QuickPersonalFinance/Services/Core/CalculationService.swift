//
//  CalculationService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import Foundation

protocol CalculationService {
    func convert(_ value: Decimal, from origin: Recurrence, to destination: Recurrence) -> Decimal
    func totalize(sources: [any Source], to recurrence: Recurrence) -> Decimal
    func makeBalance(incomes: [Income], expenses: [Expense], basedOn recurrence: Recurrence) -> Decimal
}

/// Service for calculations
class Calculation: CalculationService {

    // MARK: Properties

    private let settings: SettingsService

    // MARK: Initialization

    init(settings: SettingsService = Settings()) {
        self.settings = settings
    }

    // MARK: Behavior

    func convert(
        _ value: Decimal,
        from origin: Recurrence,
        to destination: Recurrence
    ) -> Decimal {
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
        let factor = isForward ? forwardFactor(to: next) : backwardFactor(to: next)
        guard factor != 0 else {
            return value
        }

        let newValue = isForward ? value * factor : value / factor
        return convert(newValue, from: next, to: destination)
    }

    func totalize(sources: [any Source], to recurrence: Recurrence) -> Decimal {
        sources.map { source in
            guard let sourceRecurrence = source.recurrence else {
                return source.grossValue
            }
            return convert(source.grossValue, from: sourceRecurrence, to: recurrence)
        }
        .reduce(0, +)
    }

    /// Factor to multiply by when moving one step up, into `next`.
    private func forwardFactor(to next: Recurrence) -> Decimal {
        switch next {
            case .hour:
                return 1
            case .day:
                return decimal(settings.workHoursPerDay)
            case .week:
                return decimal(settings.workDaysPerWeek)
            case .month:
                return Constant.weeksPerMonthCount
            case .year:
                return Constant.monthsPerYearCount
        }
    }

    /// Factor to divide by when moving one step down, into `next`.
    private func backwardFactor(to next: Recurrence) -> Decimal {
        switch next {
            case .hour:
                return decimal(settings.workHoursPerDay)
            case .day:
                return decimal(settings.workDaysPerWeek)
            case .week:
                return Constant.weeksPerMonthCount
            case .month:
                return Constant.monthsPerYearCount
            case .year:
                return 1
        }
    }

    /// Work-hour settings are stored as Double. Parse their decimal text so 8.5 stays 8.5.
    private func decimal(_ value: Double) -> Decimal {
        Decimal(string: String(value), locale: Locale(identifier: "en_US_POSIX")) ?? Decimal(value)
    }

    func makeBalance(
        incomes: [Income],
        expenses: [Expense],
        basedOn recurrence: Recurrence
    ) -> Decimal {
        let totalIncome = totalize(sources: incomes, to: recurrence)
        let totalExpense = totalize(sources: expenses, to: recurrence)
        return totalIncome - totalExpense
    }
}
