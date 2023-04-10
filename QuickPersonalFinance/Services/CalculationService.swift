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

class Calculation: CalculationService {
    var incomes: [Income]
    var expenses: [Expense]

    init(incomes: [Income], expenses: [Expense]) {
        self.incomes = incomes
        self.expenses = expenses
    }

    private func convert(
        _ value: Double,
        from origin: Recurrence,
        to destination: Recurrence) -> Double
    {
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
            switch next {
                case .hour:
                    factor = 1
                case .day:
                    factor = Constant.workHoursPerDay
                case .week:
                    factor = Constant.workDaysPerWeek
                case .month:
                    factor = Constant.weeksPerMonthCount
                case .year:
                    factor = Constant.monthsPerYearCount
            }
        } else {
            switch next {
                case .hour:
                    factor = Constant.workHoursPerDay
                case .day:
                    factor = Constant.workDaysPerWeek
                case .week:
                    factor = Constant.weeksPerMonthCount
                case .month:
                    factor = Constant.monthsPerYearCount
                case .year:
                    factor = 1
            }
        }

        let newValue = isForward ? value * factor : value / factor
        return convert(newValue, from: next, to: destination)
    }

    func totalize(sources: [any Source], to recurrence: Recurrence) -> Double {
        sources.map { source in
            source.recurrence != nil ?
            convert(source.netValue, from: source.recurrence!, to: recurrence) :
            source.netValue
        }.reduce(0, +)
    }

    func monthlyBalance() -> Double {
        totalize(sources: incomes, to: .month) - totalize(sources: expenses, to: .month)
    }
}
