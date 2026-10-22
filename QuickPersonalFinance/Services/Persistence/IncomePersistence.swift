//
//  IncomePersistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/4/23.
//

import CoreData

protocol IncomePersistenceService: PersistenceService,
                                    CoreDataPersistable where PersistentType == Income {}

/// Persistence service related to Income
class IncomePersistence: IncomePersistenceService {
    let moc: NSManagedObjectContext

    required init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func save(item: Income) throws {
        _ = StoredIncome.from(item, context: moc)
        try saveOrRollback()
    }

    func loadAll() throws -> [Income] {
        let request = NSFetchRequest<StoredIncome>(entityName: "\(StoredIncome.self)")
        return try moc.fetch(request).compactMap { Income.from($0) }
    }

    func load(itemWithID id: UUID) throws -> Income? {
        try loadStored(itemWithID: id).flatMap { Income.from($0) }
    }

    func update(item: Income) throws {
        guard let fetchedObject = try loadStored(itemWithID: item.id) else {
            throw PersistenceError.itemNotFound
        }
        fetchedObject.name = item.name
        fetchedObject.more = item.more
        fetchedObject.grossValue = item.grossValue
        fetchedObject.recurrence = item.recurrence?.rawValue
        try saveOrRollback()
    }

    func delete(item: Income) throws {
        try delete(items: [item])
    }

    func delete(items: [Income]) throws {
        for item in items {
            if let fetchedObject = try loadStored(itemWithID: item.id) {
                moc.delete(fetchedObject)
            }
        }
        try saveOrRollback()
    }

    private func loadStored(itemWithID id: UUID) throws -> StoredIncome? {
        let request = NSFetchRequest<StoredIncome>(entityName: "\(StoredIncome.self)")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try moc.fetch(request).first
    }
}
