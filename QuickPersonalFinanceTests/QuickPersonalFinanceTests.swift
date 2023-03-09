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
        calculation = Calculation(income: 5, expense: 4, frequency: .hour)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 160)
    }

    func testDaily() throws {
        calculation = Calculation(income: 10, expense: 9, frequency: .day)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 20)
    }

    func testWeekly() throws {
        calculation = Calculation(income: 50, expense: 40, frequency: .week)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 40)
    }

    func testMonthly() throws {
        calculation = Calculation(income: 100, expense: 90, frequency: .month)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 10)
    }

    func testYearly() throws {
        calculation = Calculation(income: 1200, expense: 1080, frequency: .year)
        let balance = calculation.monthlyBalance()
        XCTAssertEqual(balance, 10)
    }

}
