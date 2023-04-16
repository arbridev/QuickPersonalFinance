//
//  QuickPersonalFinanceTests.swift
//  QuickPersonalFinanceTests
//
//  Created by Armando Brito on 9/3/23.
//

import XCTest
@testable import QuickPersonalFinance

final class QuickPersonalFinanceTests: XCTestCase {

    var calculation: CalculationService!

    override func tearDownWithError() throws {
        calculation = nil
    }

    func testHourly() throws {
        let incomes = [Income(name: "income", more: nil, netValue: 5, recurrence: .hour)]
        let expenses = [Expense(name: "expense", more: nil, netValue: 4, recurrence: .hour)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 173.0, accuracy: 1.0)
    }

    func testDaily() throws {
        let incomes = [Income(name: "income", more: nil, netValue: 10, recurrence: .day)]
        let expenses = [Expense(name: "expense", more: nil, netValue: 9, recurrence: .day)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 21.0, accuracy: 1.0)
    }

    func testWeekly() throws {
        let incomes = [Income(name: "income", more: nil, netValue: 50, recurrence: .week)]
        let expenses = [Expense(name: "expense", more: nil, netValue: 40, recurrence: .week)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 43.0, accuracy: 1.0)
    }

    func testMonthly() throws {
        let incomes = [Income(name: "income", more: nil, netValue: 100, recurrence: .month)]
        let expenses = [Expense(name: "expense", more: nil, netValue: 90, recurrence: .month)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 10)
    }

    func testYearly() throws {
        let incomes = [Income(name: "income", more: nil, netValue: 1200, recurrence: .year)]
        let expenses = [Expense(name: "expense", more: nil, netValue: 120, recurrence: .year)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 90)
    }

    func testMixedBalance() throws {
        // Income: 5600
        let incomes = [
            Income(name: "income", more: nil, netValue: 10, recurrence: .hour),
            Income(name: "income", more: nil, netValue: 10, recurrence: .day),
            Income(name: "income", more: nil, netValue: 100, recurrence: .week),
            Income(name: "income", more: nil, netValue: 2400, recurrence: .month),
            Income(name: "income", more: nil, netValue: 12000, recurrence: .year)
        ]
        // Expense: 2800
        let expenses = [
            Expense(name: "expense", more: nil, netValue: 5, recurrence: .hour),
            Expense(name: "expense", more: nil, netValue: 5, recurrence: .day),
            Expense(name: "expense", more: nil, netValue: 50, recurrence: .week),
            Expense(name: "expense", more: nil, netValue: 1200, recurrence: .month),
            Expense(name: "expense", more: nil, netValue: 6000, recurrence: .year)
        ]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 2893.0, accuracy: 1.0)
    }

}
