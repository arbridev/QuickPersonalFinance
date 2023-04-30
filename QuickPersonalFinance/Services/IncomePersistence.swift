//
//  IncomePersistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/4/23.
//

import CoreData

protocol IncomePersistenceService: PersistenceService,
                                    CoreDataPersistable where PersistentType == Income {}

class IncomePersistence: IncomePersistenceService {
    let moc: NSManagedObjectContext

    required init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func save(item: Income) {
        _ = StoredIncome.from(item, context: moc)
        try? moc.save()
    }

    func loadAll() -> [Income] {
        let request = NSFetchRequest<StoredIncome>(entityName: "\(StoredIncome.self)")
        let fetched = try? moc.fetch(request)
        return fetched?.map({ Income.from($0) }) ?? [Income]()
    }

    func load(itemWithID id: UUID) -> Income? {
        let request = NSFetchRequest<StoredIncome>(entityName: "\(StoredIncome.self)")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        if let fetchedObject = try? moc.fetch(request).first {
            return Income.from(fetchedObject)
        }
        return nil
    }

    func update(item: Income) {
        if let fetchedObject: StoredIncome = load(itemWithID: item.id) {
            fetchedObject.name = item.name
            fetchedObject.more = item.more
            fetchedObject.grossValue = item.grossValue
            fetchedObject.recurrence = item.recurrence?.rawValue
        }
        try? moc.save()
    }

    func delete(item: Income) {
        if let fetchedObject: StoredIncome = load(itemWithID: item.id) {
            moc.delete(fetchedObject)
        }
        try? moc.save()
    }

    func delete(items: [Income]) {
        for item in items {
            if let fetchedObject: StoredIncome = load(itemWithID: item.id) {
                moc.delete(fetchedObject)
            }
        }
        try? moc.save()
    }

    private func load(itemWithID id: UUID) -> StoredIncome? {
        let request = NSFetchRequest<StoredIncome>(entityName: "\(StoredIncome.self)")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try? moc.fetch(request).first
    }
}
