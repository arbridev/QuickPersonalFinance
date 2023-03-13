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
        let incomes = [Income(netValue: 5, recurrence: .hour)]
        let expenses = [Expense(netValue: 4, recurrence: .hour)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 160)
    }

    func testDaily() throws {
        let incomes = [Income(netValue: 10, recurrence: .day)]
        let expenses = [Expense(netValue: 9, recurrence: .day)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 20)
    }

    func testWeekly() throws {
        let incomes = [Income(netValue: 50, recurrence: .week)]
        let expenses = [Expense(netValue: 40, recurrence: .week)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 40)
    }

    func testMonthly() throws {
        let incomes = [Income(netValue: 100, recurrence: .month)]
        let expenses = [Expense(netValue: 90, recurrence: .month)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 10)
    }

    func testYearly() throws {
        let incomes = [Income(netValue: 1200, recurrence: .year)]
        let expenses = [Expense(netValue: 120, recurrence: .year)]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 90)
    }

    func testMixedBalance() throws {
        // Income: 5600
        let incomes = [
            Income(netValue: 10, recurrence: .hour),
            Income(netValue: 10, recurrence: .day),
            Income(netValue: 100, recurrence: .week),
            Income(netValue: 2400, recurrence: .month),
            Income(netValue: 12000, recurrence: .year)
        ]
        // Expense: 2800
        let expenses = [
            Expense(netValue: 5, recurrence: .hour),
            Expense(netValue: 5, recurrence: .day),
            Expense(netValue: 50, recurrence: .week),
            Expense(netValue: 1200, recurrence: .month),
            Expense(netValue: 6000, recurrence: .year)
        ]
        calculation = Calculation(incomes: incomes, expenses: expenses)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 2800)
    }

}
