//
//  StoreMigrator.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 23/10/26.
//

import CoreData

/// Migrates stores whose money amounts are Doubles to the model that stores them as Decimals.
/// Lightweight migration cannot change an attribute's type, so this reads the old store and
/// writes a new one.
enum StoreMigrator {

    enum MigrationError: Error {
        case modelNotFound
        case unknownStoreVersion
    }

    static func migrateStoreIfNeeded(at storeURL: URL) throws {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return
        }
        let models = try loadModels()
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL
        )
        if models.current.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
            return
        }
        guard let source = models.previous.first(where: {
            $0.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }) else {
            throw MigrationError.unknownStoreVersion
        }

        let snapshot = try read(storeAt: storeURL, model: source)
        let migratedURL = storeURL.deletingLastPathComponent()
            .appendingPathComponent("\(storeURL.lastPathComponent).migrated")
        try? destroyStore(at: migratedURL, model: models.current)
        try write(snapshot, to: migratedURL, model: models.current)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models.current)
        try coordinator.replacePersistentStore(
            at: storeURL,
            destinationOptions: nil,
            withPersistentStoreFrom: migratedURL,
            sourceOptions: nil,
            ofType: NSSQLiteStoreType
        )
        try coordinator.destroyPersistentStore(at: migratedURL, ofType: NSSQLiteStoreType, options: nil)
    }

    /// A compiled model version inside the app's momd. `QuickPersonalFinance` is the original store.
    static func compiledModel(named name: String) throws -> NSManagedObjectModel {
        guard let momdURL = Bundle(for: DataController.self)
            .url(forResource: "QuickPersonalFinance", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("\(name).mom")) else {
            throw MigrationError.modelNotFound
        }
        return model
    }

    // MARK: - Models

    private static func loadModels() throws -> (current: NSManagedObjectModel, previous: [NSManagedObjectModel]) {
        guard let momdURL = Bundle(for: DataController.self)
            .url(forResource: "QuickPersonalFinance", withExtension: "momd"),
              let current = NSManagedObjectModel(contentsOf: momdURL) else {
            throw MigrationError.modelNotFound
        }
        let momURLs = try FileManager.default.contentsOfDirectory(at: momdURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "mom" }
        let previous = momURLs.compactMap { NSManagedObjectModel(contentsOf: $0) }.filter {
            $0.entityVersionHashesByName != current.entityVersionHashesByName
        }
        return (current, previous)
    }

    /// The class Core Data would instantiate is compiled for the current model.
    /// Reading an older store uses plain NSManagedObject so a Decimal property is not
    /// applied to a Double column.
    private static func readableCopy(of model: NSManagedObjectModel) -> NSManagedObjectModel {
        let copy = model.copy() as! NSManagedObjectModel
        copy.entities.forEach { $0.managedObjectClassName = NSStringFromClass(NSManagedObject.self) }
        return copy
    }

    // MARK: - Read

    private struct SourceRow {
        var id: UUID?
        var name: String?
        var more: String?
        var grossValue: Decimal
        var recurrence: String?
    }

    private struct CurrencyRow {
        var lastUpdate: Date?
        var data: Data?
    }

    private struct Snapshot {
        var incomes: [SourceRow]
        var expenses: [SourceRow]
        var currencies: [CurrencyRow]
    }

    private static func read(storeAt storeURL: URL, model: NSManagedObjectModel) throws -> Snapshot {
        let readable = readableCopy(of: model)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: readable)
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL
        )
        defer { try? coordinator.remove(store) }

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        var snapshot: Snapshot?
        var readError: Error?
        context.performAndWait {
            do {
                snapshot = Snapshot(
                    incomes: try rows(named: "StoredIncome", in: context),
                    expenses: try rows(named: "StoredExpense", in: context),
                    currencies: try currencyRows(in: context)
                )
            } catch {
                readError = error
            }
        }
        if let readError {
            throw readError
        }
        return snapshot ?? Snapshot(incomes: [], expenses: [], currencies: [])
    }

    private static func rows(named entityName: String, in context: NSManagedObjectContext) throws -> [SourceRow] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        return try context.fetch(request).map { object in
            let number = object.value(forKey: "grossValue") as? NSNumber
            return SourceRow(
                id: object.value(forKey: "id") as? UUID,
                name: object.value(forKey: "name") as? String,
                more: object.value(forKey: "more") as? String,
                grossValue: number.map(decimal(fromStoredDouble:)) ?? 0,
                recurrence: object.value(forKey: "recurrence") as? String
            )
        }
    }

    private static func currencyRows(in context: NSManagedObjectContext) throws -> [CurrencyRow] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "StoredCurrencyData")
        return try context.fetch(request).map { object in
            CurrencyRow(
                lastUpdate: object.value(forKey: "lastUpdate") as? Date,
                data: object.value(forKey: "data") as? Data
            )
        }
    }

    /// The old column is a binary floating-point value. Round to 4 places to drop the noise
    /// that representation adds to amounts such as 0.1.
    static func decimal(fromStoredDouble number: NSNumber) -> Decimal {
        var value = Decimal(number.doubleValue)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 4, .plain)
        return rounded
    }

    // MARK: - Write

    private static func write(_ snapshot: Snapshot, to storeURL: URL, model: NSManagedObjectModel) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL
        )
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        var writeError: Error?
        context.performAndWait {
            do {
                for row in snapshot.incomes {
                    let income = StoredIncome(context: context)
                    apply(row, to: income)
                }
                for row in snapshot.expenses {
                    let expense = StoredExpense(context: context)
                    apply(row, to: expense)
                }
                for row in snapshot.currencies {
                    let currency = StoredCurrencyData(context: context)
                    currency.lastUpdate = row.lastUpdate
                    currency.data = row.data
                }
                try context.save()
            } catch {
                writeError = error
            }
        }
        try? coordinator.remove(store)
        if let writeError {
            throw writeError
        }
    }

    private static func apply(_ row: SourceRow, to source: StoredSource) {
        source.id = row.id
        source.name = row.name
        source.more = row.more
        source.money = row.grossValue
        source.recurrence = row.recurrence
    }

    private static func destroyStore(at storeURL: URL, model: NSManagedObjectModel) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
    }
}
