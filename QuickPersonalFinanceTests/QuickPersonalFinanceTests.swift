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

        try persistence.save(item: currencies)
        XCTAssertNotNil(try persistence.load())
        try persistence.delete()
        XCTAssertNil(try persistence.load())
    }

    func testExpensePersistenceRoundTrip() throws {
        let controller = DataController(inMemory: true)
        let persistence = ExpensePersistence(moc: controller.container.viewContext)
        let expense = Expense(id: UUID(), name: "expense", more: nil, grossValue: 10, recurrence: .month)

        try persistence.save(item: expense)
        XCTAssertEqual(try persistence.load(itemWithID: expense.id)?.name, "expense")

        let edited = Expense(id: expense.id, name: "edited", more: "more", grossValue: 20, recurrence: .year)
        try persistence.update(item: edited)
        XCTAssertEqual(try persistence.load(itemWithID: expense.id), edited)

        try persistence.delete(item: edited)
        XCTAssertNil(try persistence.load(itemWithID: expense.id))
        XCTAssertTrue(try persistence.loadAll().isEmpty)
    }

    func testIncomePersistenceRoundTrip() throws {
        let controller = DataController(inMemory: true)
        let persistence = IncomePersistence(moc: controller.container.viewContext)
        let incomes = [
            Income(id: UUID(), name: "first", more: nil, grossValue: 10, recurrence: .month),
            Income(id: UUID(), name: "second", more: nil, grossValue: 20, recurrence: .week)
        ]
        try incomes.forEach { try persistence.save(item: $0) }

        let edited = Income(id: incomes[0].id, name: "edited", more: nil, grossValue: 15, recurrence: .day)
        try persistence.update(item: edited)
        XCTAssertEqual(try persistence.load(itemWithID: edited.id), edited)

        try persistence.delete(items: incomes)
        XCTAssertTrue(try persistence.loadAll().isEmpty)
    }

    func testUpdateMissingItemThrows() throws {
        let controller = DataController(inMemory: true)
        let persistence = ExpensePersistence(moc: controller.container.viewContext)
        let expense = Expense(id: UUID(), name: "missing", more: nil, grossValue: 1, recurrence: .day)

        XCTAssertThrowsError(try persistence.update(item: expense)) { error in
            guard case PersistenceError.itemNotFound = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testStoredRowWithoutIDIsSkipped() throws {
        let controller = DataController(inMemory: true)
        let context = controller.container.viewContext
        let persistence = IncomePersistence(moc: context)
        let stored = StoredIncome(context: context)
        stored.name = "no id"
        try context.save()

        XCTAssertTrue(try persistence.loadAll().isEmpty)
    }

    func testArraySubtracting() {
        XCTAssertEqual([1, 2, 3, 4].subtracting([2, 4]), [1, 3])
        XCTAssertEqual([1, 2].subtracting([2, 5]), [1])
        XCTAssertEqual([Int]().subtracting([1]), [])
    }

    func testTotalizeWithoutRecurrenceUsesGrossValue() {
        let incomes = [
            Income(id: UUID(), name: "fixed", more: nil, grossValue: 7, recurrence: nil),
            Income(id: UUID(), name: "monthly", more: nil, grossValue: 12, recurrence: .month)
        ]
        calculation = Calculation()
        XCTAssertEqual(calculation.totalize(sources: incomes, to: .month), 19)
    }

    func testCurrencyConversionWithZeroRateThrows() throws {
        var currencies = MockData.latestCurrencies.data
        currencies["EUR"] = Currency(code: "EUR", value: 0)
        let currencyCalc = try XCTUnwrap(Calculation.CurrencyCalculation(currencies))

        XCTAssertThrowsError(try currencyCalc.convert(20, from: "EUR", to: "USD")) { error in
            XCTAssertEqual(error as? Calculation.CurrencyCalculationError, .invalidRate)
        }
    }

    func testSettingsUsesInjectedDefaults() throws {
        let suiteName = "test-\(#function)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var settings = Settings(persistence: defaults)
        settings.workHoursPerDay = 6

        XCTAssertEqual(defaults.double(forKey: Settings.StorageKey.workHoursPerDay.rawValue), 6)
        XCTAssertEqual(Settings(persistence: defaults).workHoursPerDay, 6)
    }

    func testCurrencyConversionUSDtoEUR() throws {
        let currencies = MockData.latestCurrencies.data
        guard let currencyCalc = Calculation.CurrencyCalculation(currencies) else {
            fatalError("Could not initialize currency calculation")
        }
        let value = 20.0
        let converted = try currencyCalc.convert(value, from: "USD", to: "EUR")
        let expected = 18.4
        XCTAssertEqual(converted, expected, accuracy: 0.2)
    }

    func testCurrencyConversionEURtoUSD() throws {
        let currencies = MockData.latestCurrencies.data
        guard let currencyCalc = Calculation.CurrencyCalculation(currencies) else {
            fatalError("Could not initialize currency calculation")
        }
        let value = 20.0
        let converted = try currencyCalc.convert(value, from: "EUR", to: "USD")
        let expected = 21.73
        XCTAssertEqual(converted, expected, accuracy: 0.2)
    }

    func testCurrencyConversionVEStoEUR() throws {
        let currencies = MockData.latestCurrencies.data
        guard let currencyCalc = Calculation.CurrencyCalculation(currencies) else {
            fatalError("Could not initialize currency calculation")
        }
        let value = 60.0
        let converted = try currencyCalc.convert(value, from: "VES", to: "EUR")
        let expected = 2.12
        XCTAssertEqual(converted.rounded(toPlaces: 2), expected, accuracy: 0.2)
    }
}

fileprivate extension QuickPersonalFinanceTests {
    actor ExternalCurrencyMock: ExternalCurrencyService {
        func fetchLatestCurrencies() async throws -> QuickPersonalFinance.LatestCurrencies {
            MockData.latestCurrencies
        }
    }
}
