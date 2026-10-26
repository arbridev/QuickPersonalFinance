//
//  QuickPersonalFinanceTests.swift
//  QuickPersonalFinanceTests
//
//  Created by Armando Brito on 9/3/23.
//

import XCTest
import CoreData
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
        XCTAssertEqual(balance, Decimal(string: "173.6")!)
    }

    func testDaily() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 10, recurrence: .day)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 9, recurrence: .day)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, Decimal(string: "21.7")!)
    }

    func testWeekly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 50, recurrence: .week)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 40, recurrence: .week)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, Decimal(string: "43.4")!)
    }

    func testMonthly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 100, recurrence: .month)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 90, recurrence: .month)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, Decimal(10))
    }

    func testYearly() throws {
        let incomes = [Income(id: UUID(), name: "income", more: nil, grossValue: 1200, recurrence: .year)]
        let expenses = [Expense(id: UUID(), name: "expense", more: nil, grossValue: 120, recurrence: .year)]
        calculation = Calculation()
        let balance = calculation.makeBalance(incomes: incomes, expenses: expenses, basedOn: .month)
        XCTAssertEqual(balance, Decimal(90))
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
        XCTAssertEqual(balance, Decimal(string: "2893.5")!)
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
        XCTAssertEqual(calculation.totalize(sources: incomes, to: .month), Decimal(19))
    }

    func testCurrencyConversionWithZeroRateThrows() throws {
        var currencies = MockData.latestCurrencies.data
        currencies["EUR"] = Currency(code: "EUR", value: 0)
        let currencyCalc = try XCTUnwrap(Calculation.CurrencyCalculation(currencies))

        XCTAssertThrowsError(try currencyCalc.convert(20, from: "EUR", to: "USD")) { error in
            XCTAssertEqual(error as? Calculation.CurrencyCalculationError, .invalidRate)
        }
    }

    func testEstimateSummaryFromFinanceData() {
        let financeData = FinanceData(
            incomes: [Income(id: UUID(), name: "income", more: nil, grossValue: 1200, recurrence: .year)],
            expenses: [Expense(id: UUID(), name: "expense", more: nil, grossValue: 40, recurrence: .month)]
        )
        let summary = EstimateSummary(
            financeData: financeData,
            recurrence: .month,
            currencyID: "USD",
            calculation: Calculation()
        )

        XCTAssertEqual(summary.incomeTotal, Decimal(100))
        XCTAssertEqual(summary.expenseTotal, Decimal(40))
        XCTAssertEqual(summary.balance, Decimal(60))
        XCTAssertEqual(summary.currencyID, "USD")
    }

    @MainActor
    func testEstimateViewModelUsesInjectedSettings() throws {
        let suiteName = "test-\(#function)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        var settings = Settings(persistence: defaults)
        settings.workHoursPerDay = 10
        settings.currencyID = "EUR"

        let mainData = AppData()
        mainData.financeData = FinanceData(
            incomes: [Income(id: UUID(), name: "hourly", more: nil, grossValue: 2, recurrence: .hour)],
            expenses: []
        )
        let viewModel = EstimateView.ViewModel(settings: settings)
        viewModel.input(mainData: mainData)
        viewModel.selectedRecurrence = .day

        XCTAssertEqual(viewModel.summary.incomeTotal, Decimal(20))
        XCTAssertEqual(viewModel.summary.currencyID, "EUR")
    }

    func testMigratesDoubleMoneyToDecimal() throws {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("money-migration-\(UUID().uuidString).sqlite")
        defer {
            ["", "-wal", "-shm"].forEach { suffix in
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + suffix))
            }
        }

        let source = try StoreMigrator.compiledModel(named: "QuickPersonalFinance")
        let writable = source.copy() as! NSManagedObjectModel
        writable.entities.forEach { $0.managedObjectClassName = NSStringFromClass(NSManagedObject.self) }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: writable)
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let income = NSManagedObject(entity: writable.entitiesByName["StoredIncome"]!, insertInto: context)
        income.setValue(10.5, forKey: "grossValue")
        income.setValue(UUID(), forKey: "id")
        income.setValue("salary", forKey: "name")

        let expense = NSManagedObject(entity: writable.entitiesByName["StoredExpense"]!, insertInto: context)
        expense.setValue(0.1, forKey: "grossValue")
        expense.setValue(UUID(), forKey: "id")
        expense.setValue("tax", forKey: "name")

        let currency = NSManagedObject(entity: writable.entitiesByName["StoredCurrencyData"]!, insertInto: context)
        currency.setValue(Date(timeIntervalSince1970: 1_700_000_000), forKey: "lastUpdate")
        try context.save()
        try coordinator.remove(store)

        try StoreMigrator.migrateStoreIfNeeded(at: storeURL)

        let container = NSPersistentContainer(name: "QuickPersonalFinance")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = false
        container.persistentStoreDescriptions = [description]
        let loaded = expectation(description: "migrated store")
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
        XCTAssertNil(loadError)

        let incomes = try container.viewContext.fetch(NSFetchRequest<StoredIncome>(entityName: "StoredIncome"))
        XCTAssertEqual(incomes.first?.name, "salary")
        XCTAssertEqual(incomes.first?.money, Decimal(string: "10.5"))
        XCTAssertNil(incomes.first?.firstPaymentDate)
        XCTAssertNil(incomes.first?.lastPaymentDate)
        let expenses = try container.viewContext.fetch(NSFetchRequest<StoredExpense>(entityName: "StoredExpense"))
        XCTAssertEqual(expenses.first?.money, Decimal(string: "0.1"))
        let currencies = try container.viewContext.fetch(
            NSFetchRequest<StoredCurrencyData>(entityName: "StoredCurrencyData")
        )
        XCTAssertEqual(currencies.count, 1)
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

    func testParseMoneyKeepsFractionalPart() {
        XCTAssertEqual(Decimal.parseMoney("19.99"), Decimal(string: "19.99"))
        XCTAssertEqual(Decimal.parseMoney("10,50"), Decimal(string: "10.50"))
        XCTAssertEqual(Decimal.parseMoney("0,5"), Decimal(string: "0.5"))
        XCTAssertNil(Decimal.parseMoney("1,234.56"))
        XCTAssertNil(Decimal.parseMoney("10.5abc"))
    }

    func testFractionalGrossValueRoundTrip() throws {
        let controller = DataController(inMemory: true)
        let persistence = IncomePersistence(moc: controller.container.viewContext)
        let amount = Decimal(string: "19.99")!
        let income = Income(id: UUID(), name: "salary", more: nil, grossValue: amount, recurrence: .month)

        try persistence.save(item: income)
        XCTAssertEqual(try persistence.load(itemWithID: income.id)?.grossValue, amount)

        let edited = Income(
            id: income.id,
            name: "salary",
            more: nil,
            grossValue: Decimal(string: "10.5")!,
            recurrence: .month
        )
        try persistence.update(item: edited)
        XCTAssertEqual(try persistence.load(itemWithID: income.id)?.grossValue, edited.grossValue)
    }

    func testCurrencyConversionUSDtoEUR() throws {
        let currencies = MockData.latestCurrencies.data
        guard let currencyCalc = Calculation.CurrencyCalculation(currencies) else {
            fatalError("Could not initialize currency calculation")
        }
        let converted = try currencyCalc.convert(20, from: "USD", to: "EUR")
        XCTAssertEqual(converted, Decimal(string: "18.4")!, accuracy: Decimal(string: "0.2")!)
    }

    func testCurrencyConversionEURtoUSD() throws {
        let currencies = MockData.latestCurrencies.data
        guard let currencyCalc = Calculation.CurrencyCalculation(currencies) else {
            fatalError("Could not initialize currency calculation")
        }
        let converted = try currencyCalc.convert(20, from: "EUR", to: "USD")
        XCTAssertEqual(converted, Decimal(string: "21.73")!, accuracy: Decimal(string: "0.2")!)
    }

    func testCurrencyConversionVEStoEUR() throws {
        let currencies = MockData.latestCurrencies.data
        guard let currencyCalc = Calculation.CurrencyCalculation(currencies) else {
            fatalError("Could not initialize currency calculation")
        }
        let converted = try currencyCalc.convert(60, from: "VES", to: "EUR")
        XCTAssertEqual(
            converted.rounded(toPlaces: 2),
            Decimal(string: "2.12")!,
            accuracy: Decimal(string: "0.2")!
        )
    }
}

private func XCTAssertEqual(
    _ expression: Decimal,
    _ expected: Decimal,
    accuracy: Decimal,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertLessThanOrEqual(abs(expression - expected), accuracy, file: file, line: line)
}

fileprivate extension QuickPersonalFinanceTests {
    actor ExternalCurrencyMock: ExternalCurrencyService {
        func fetchLatestCurrencies() async throws -> QuickPersonalFinance.LatestCurrencies {
            MockData.latestCurrencies
        }
    }
}
