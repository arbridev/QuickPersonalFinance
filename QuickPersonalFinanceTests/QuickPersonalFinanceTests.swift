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
        try super.tearDownWithError()
        calculation = nil
    }

    func testHourly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 5, recurrence: .hour)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 4, recurrence: .hour)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, 173.0, accuracy: 1.0)
    }

    func testDaily() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 10, recurrence: .day)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 9, recurrence: .day)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, 21.0, accuracy: 1.0)
    }

    func testWeekly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 50, recurrence: .week)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 40, recurrence: .week)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, 43.0, accuracy: 1.0)
    }

    func testMonthly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 100, recurrence: .month)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 90, recurrence: .month)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, 10)
    }

    func testYearly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 1200, recurrence: .year)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 120, recurrence: .year)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, 90)
    }

    func testMixedBalance() throws {
        // Income: 5600
        let incomes = [
            Income(id: UUID(), name: "income", more: nil, grossValue: 10, recurrence: .hour),
            Income(id: UUID(), name: "income", more: nil, grossValue: 10, recurrence: .day),
            Income(id: UUID(), name: "income", more: nil, grossValue: 100, recurrence: .week),
            Income(id: UUID(), name: "income", more: nil, grossValue: 2400, recurrence: .month),
            Income(id: UUID(), name: "income", more: nil, grossValue: 12000, recurrence: .year)
        ]
        // Expense: 2800
        let expenses = [
            Expense(id: UUID(), name: "expense", more: nil, grossValue: 5, recurrence: .hour),
            Expense(id: UUID(), name: "expense", more: nil, grossValue: 5, recurrence: .day),
            Expense(id: UUID(), name: "expense", more: nil, grossValue: 50, recurrence: .week),
            Expense(id: UUID(), name: "expense", more: nil, grossValue: 1200, recurrence: .month),
            Expense(id: UUID(), name: "expense", more: nil, grossValue: 6000, recurrence: .year)
        ]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, 2893.0, accuracy: 1.0)
    }

    // swiftlint:disable todo
    // TODO: Change to a functional implementation where the mock is not the test subject
    func testExternalCurrencyMock() throws {
        let externalCurrency = ExternalCurrencyMock()
        let expectation = XCTestExpectation(description: "Fetch latest currencies")
        Task.detached {
            do {
                let currencies = try await externalCurrency.fetchLatestCurrencies()
                guard let usd = currencies.data["USD"] else {
                    XCTFail("No USD data present")
                    return
                }
                XCTAssertEqual(usd.value, 1.0)
                expectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    // swiftlint:enable todo

    func testCurrencyPersistence() throws {
        let currencies = MockData.latestCurrencies
        let controller = DataController(inMemory: true)
        let context = controller.container.newBackgroundContext()
        let persistence = CurrencyDataPersistence(moc: context)

        persistence.save(item: currencies)
        XCTAssertNotNil(persistence.load())
        persistence.delete()
        XCTAssertNil(persistence.load())
    }

}

fileprivate extension QuickPersonalFinanceTests {
    actor ExternalCurrencyMock: ExternalCurrencyService {
        func fetchLatestCurrencies() async throws -> QuickPersonalFinance.LatestCurrencies {
            MockData.latestCurrencies
        }
    }
}
