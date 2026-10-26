//
//  PaymentDateTests.swift
//  QuickPersonalFinanceTests
//
//  Created by Armando Brito on 26/10/26.
//

import XCTest
import CoreData
@testable import QuickPersonalFinance

final class PaymentDateTests: XCTestCase {

    func testNextPaymentStepsForward() {
        let calendar = utcCalendar()
        let hourly = income(.hour, first: date(2026, 3, 10, 9, 15, calendar: calendar))
        XCTAssertEqual(
            hourly.nextPaymentDate(from: date(2026, 3, 10, 11, 40, calendar: calendar), calendar: calendar),
            date(2026, 3, 10, 12, 15, calendar: calendar)
        )

        let daily = income(.day, first: date(2026, 3, 1, calendar: calendar))
        XCTAssertEqual(
            daily.nextPaymentDate(from: date(2026, 3, 10, 15, calendar: calendar), calendar: calendar),
            date(2026, 3, 10, calendar: calendar)
        )

        let weekly = income(.week, first: date(2026, 1, 5, calendar: calendar))
        XCTAssertEqual(
            weekly.nextPaymentDate(from: date(2026, 1, 14, 12, calendar: calendar), calendar: calendar),
            date(2026, 1, 19, calendar: calendar)
        )

        let monthly = income(.month, first: date(2026, 1, 31, calendar: calendar))
        XCTAssertEqual(
            monthly.nextPaymentDate(from: date(2026, 2, 1, calendar: calendar), calendar: calendar),
            date(2026, 2, 28, calendar: calendar)
        )
        XCTAssertEqual(
            monthly.nextPaymentDate(from: date(2026, 3, 1, calendar: calendar), calendar: calendar),
            date(2026, 3, 31, calendar: calendar)
        )

        let yearly = income(.year, first: date(2024, 6, 15, calendar: calendar))
        XCTAssertEqual(
            yearly.nextPaymentDate(from: date(2026, 1, 1, calendar: calendar), calendar: calendar),
            date(2026, 6, 15, calendar: calendar)
        )
    }

    func testNextPaymentRespectsBounds() {
        let calendar = utcCalendar()
        let future = income(.month, first: date(2026, 4, 1, calendar: calendar))
        XCTAssertEqual(
            future.nextPaymentDate(from: date(2026, 3, 10, 15, calendar: calendar), calendar: calendar),
            date(2026, 4, 1, calendar: calendar)
        )

        let dueToday = income(.month, first: date(2026, 1, 15, calendar: calendar))
        XCTAssertEqual(
            dueToday.nextPaymentDate(from: date(2026, 3, 15, 18, calendar: calendar), calendar: calendar),
            date(2026, 3, 15, calendar: calendar)
        )

        let ended = income(
            .month,
            first: date(2026, 1, 1, calendar: calendar),
            last: date(2026, 2, 1, calendar: calendar)
        )
        XCTAssertNil(ended.nextPaymentDate(from: date(2026, 3, 10, calendar: calendar), calendar: calendar))

        let endsToday = income(
            .month,
            first: date(2026, 1, 10, calendar: calendar),
            last: date(2026, 3, 10, calendar: calendar)
        )
        XCTAssertEqual(
            endsToday.nextPaymentDate(from: date(2026, 3, 10, 15, calendar: calendar), calendar: calendar),
            date(2026, 3, 10, calendar: calendar)
        )

        let invalid = PaymentDateSelection(
            firstPaymentDate: date(2026, 3, 10, 12, calendar: calendar),
            includesLastPayment: true,
            lastPaymentDate: date(2026, 3, 10, 9, calendar: calendar),
            recurrence: .hour
        )
        XCTAssertFalse(invalid.isValid(calendar: calendar))
    }

    func testNilFirstPaymentUsesPeriodStart() {
        var calendar = utcCalendar()
        calendar.firstWeekday = 2
        let duringMarch = date(2026, 3, 10, 15, calendar: calendar)

        let monthly = Income(id: UUID(), name: "income", more: nil, grossValue: 1, recurrence: .month)
        XCTAssertEqual(
            monthly.nextPaymentDate(from: duringMarch, calendar: calendar),
            date(2026, 4, 1, calendar: calendar)
        )
        XCTAssertEqual(
            monthly.nextPaymentDate(from: date(2026, 3, 1, 8, calendar: calendar), calendar: calendar),
            date(2026, 3, 1, calendar: calendar)
        )

        let yearly = Income(id: UUID(), name: "income", more: nil, grossValue: 1, recurrence: .year)
        XCTAssertEqual(
            yearly.nextPaymentDate(from: duringMarch, calendar: calendar),
            date(2027, 1, 1, calendar: calendar)
        )

        let weekly = Income(id: UUID(), name: "income", more: nil, grossValue: 1, recurrence: .week)
        XCTAssertEqual(
            weekly.nextPaymentDate(from: duringMarch, calendar: calendar),
            date(2026, 3, 16, calendar: calendar)
        )

        let selection = PaymentDateSelection(
            first: nil,
            last: nil,
            recurrence: .month,
            now: duringMarch,
            calendar: calendar
        )
        XCTAssertTrue(selection.firstPaymentDateIsPlaceholder)
        XCTAssertEqual(selection.firstPaymentDate, date(2026, 3, 1, calendar: calendar))
        XCTAssertNil(selection.persistedDates(calendar: calendar).first)
    }

    func testPaymentDatesRoundTrip() throws {
        let controller = DataController(inMemory: true)
        let incomes = IncomePersistence(moc: controller.container.viewContext)
        let expenses = ExpensePersistence(moc: controller.container.viewContext)
        let first = Date(timeIntervalSince1970: 1_700_000_000)
        let last = Date(timeIntervalSince1970: 1_800_000_000)
        let income = Income(
            id: UUID(),
            name: "salary",
            more: nil,
            grossValue: 10,
            recurrence: .month,
            firstPaymentDate: first,
            lastPaymentDate: last
        )
        let expense = Expense(
            id: UUID(),
            name: "rent",
            more: nil,
            grossValue: 5,
            recurrence: .month,
            firstPaymentDate: first,
            lastPaymentDate: last
        )

        try incomes.save(item: income)
        try expenses.save(item: expense)
        XCTAssertEqual(try incomes.load(itemWithID: income.id)?.firstPaymentDate, first)
        XCTAssertEqual(try incomes.load(itemWithID: income.id)?.lastPaymentDate, last)
        XCTAssertEqual(try expenses.load(itemWithID: expense.id)?.firstPaymentDate, first)
        XCTAssertEqual(try expenses.load(itemWithID: expense.id)?.lastPaymentDate, last)

        let cleared = Income(
            id: income.id,
            name: "salary",
            more: nil,
            grossValue: 10,
            recurrence: .month,
            firstPaymentDate: first,
            lastPaymentDate: nil
        )
        try incomes.update(item: cleared)
        XCTAssertEqual(try incomes.load(itemWithID: income.id)?.firstPaymentDate, first)
        XCTAssertNil(try incomes.load(itemWithID: income.id)?.lastPaymentDate)
    }

    func testMigratesDecimalStoreKeepingAmountsAndEmptyDates() throws {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("decimal-migration-\(UUID().uuidString).sqlite")
        defer {
            ["", "-wal", "-shm"].forEach { suffix in
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + suffix))
            }
        }

        let source = try StoreMigrator.compiledModel(named: "QuickPersonalFinance 2")
        let writable = source.copy() as! NSManagedObjectModel
        writable.entities.forEach { $0.managedObjectClassName = NSStringFromClass(NSManagedObject.self) }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: writable)
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let stored = NSManagedObject(entity: writable.entitiesByName["StoredIncome"]!, insertInto: context)
        stored.setValue(NSDecimalNumber(string: "19.99"), forKey: "grossValue")
        stored.setValue(UUID(), forKey: "id")
        stored.setValue("salary", forKey: "name")
        try context.save()
        try coordinator.remove(store)

        try StoreMigrator.migrateStoreIfNeeded(at: storeURL)

        let container = NSPersistentContainer(name: "QuickPersonalFinance")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = false
        container.persistentStoreDescriptions = [description]
        let loaded = expectation(description: "migrated decimal store")
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
        XCTAssertNil(loadError)

        let incomes = try container.viewContext.fetch(NSFetchRequest<StoredIncome>(entityName: "StoredIncome"))
        XCTAssertEqual(incomes.first?.money, Decimal(string: "19.99"))
        XCTAssertNil(incomes.first?.firstPaymentDate)
        XCTAssertNil(incomes.first?.lastPaymentDate)
    }
}

private func utcCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}

private func date(
    _ year: Int,
    _ month: Int,
    _ day: Int,
    _ hour: Int = 0,
    _ minute: Int = 0,
    calendar: Calendar
) -> Date {
    DateComponents(
        calendar: calendar,
        timeZone: calendar.timeZone,
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    ).date!
}

private func income(_ recurrence: Recurrence, first: Date, last: Date? = nil) -> Income {
    Income(
        id: UUID(),
        name: "income",
        more: nil,
        grossValue: 1,
        recurrence: recurrence,
        firstPaymentDate: first,
        lastPaymentDate: last
    )
}
