//
//  CalculationService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import Foundation

enum CalculationFrequency {
    case hour, day, week, month, year
}

protocol CalculationService {
    var income: Double { get set }
    var expense: Double { get set }
    var frequency: CalculationFrequency { get set }
    func monthlyBalance() -> Double
}

class Calculation: CalculationService {
    var income: Double
    var expense: Double
    var frequency: CalculationFrequency

    init(income: Double, expense: Double, frequency: CalculationFrequency) {
        self.income = income
        self.expense = expense
        self.frequency = frequency
    }

    func monthlyBalance() -> Double {
        switch frequency {
            case .hour:
                return (income - expense) *
                Double(Constant.workHoursPerDay) *
                Double(Constant.workDaysPerWeek) *
                Double(Constant.weeksPerMonthCount)
            case .day:
                return (income - expense) *
                Double(Constant.workDaysPerWeek) *
                Double(Constant.weeksPerMonthCount)
            case .week:
                return (income - expense) * Double(Constant.weeksPerMonthCount)
            case .year:
                return (income - expense) / Double(Constant.monthsPerYearCount)
            default:
                return income - expense
        }
    }
}
