//
//  ExpensePersistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 20/4/23.
//

import CoreData

protocol ExpensePersistenceService: PersistenceService,
                                    CoreDataPersistable where PersistentType == Expense {}

/// Persistence service related to Expense
class ExpensePersistence: ExpensePersistenceService {
    let moc: NSManagedObjectContext

    required init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func save(item: Expense) throws {
        _ = StoredExpense.from(item, context: moc)
        try saveOrRollback()
    }

    func loadAll() throws -> [Expense] {
        let request = NSFetchRequest<StoredExpense>(entityName: "\(StoredExpense.self)")
        return try moc.fetch(request).compactMap { Expense.from($0) }
    }

    func load(itemWithID id: UUID) throws -> Expense? {
        try loadStored(itemWithID: id).flatMap { Expense.from($0) }
    }

    func update(item: Expense) throws {
        guard let fetchedObject = try loadStored(itemWithID: item.id) else {
            throw PersistenceError.itemNotFound
        }
        fetchedObject.name = item.name
        fetchedObject.more = item.more
        fetchedObject.money = item.grossValue
        fetchedObject.recurrence = item.recurrence?.rawValue
        try saveOrRollback()
    }

    func delete(item: Expense) throws {
        try delete(items: [item])
    }

    func delete(items: [Expense]) throws {
        for item in items {
            if let fetchedObject = try loadStored(itemWithID: item.id) {
                moc.delete(fetchedObject)
            }
        }
        try saveOrRollback()
    }

    private func loadStored(itemWithID id: UUID) throws -> StoredExpense? {
        let request = NSFetchRequest<StoredExpense>(entityName: "\(StoredExpense.self)")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try moc.fetch(request).first
    }
}
