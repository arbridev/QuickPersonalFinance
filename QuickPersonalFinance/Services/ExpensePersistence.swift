//
//  ExpensePersistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 20/4/23.
//

import CoreData

protocol ExpensePersistenceService: PersistenceService,
                                    CoreDataPersistable where T == Expense {}

class ExpensePersistence: ExpensePersistenceService {
    let moc: NSManagedObjectContext

    required init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func save(item: Expense) {
        let _ = StoredExpense.from(item, context: moc)
        try? moc.save()
    }

    func loadAll() -> [Expense] {
        let request = NSFetchRequest<StoredExpense>(entityName: "\(StoredExpense.self)")
        let fetched = try? moc.fetch(request)
        return fetched?.map({ Expense.from($0) }) ?? [Expense]()
    }

    func load(itemWithID id: UUID) -> Expense? {
        let request = NSFetchRequest<StoredExpense>(entityName: "\(StoredExpense.self)")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        if let fetchedObject = try? moc.fetch(request).first {
            return Expense.from(fetchedObject)
        }
        return nil
    }

    func update(item: Expense) {
        if let fetchedObject: StoredExpense = load(itemWithID: item.id) {
            fetchedObject.name = item.name
            fetchedObject.more = item.more
            fetchedObject.grossValue = item.grossValue
            fetchedObject.recurrence = item.recurrence?.rawValue
        }
        try? moc.save()
    }

    func delete(item: Expense) {
        if let fetchedObject: StoredExpense = load(itemWithID: item.id) {
            moc.delete(fetchedObject)
        }
        try? moc.save()
    }

    func delete(items: [Expense]) {
        for item in items {
            if let fetchedObject: StoredExpense = load(itemWithID: item.id) {
                moc.delete(fetchedObject)
            }
        }
        try? moc.save()
    }

    private func load(itemWithID id: UUID) -> StoredExpense? {
        let request = NSFetchRequest<StoredExpense>(entityName: "\(StoredExpense.self)")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try? moc.fetch(request).first
    }
}
