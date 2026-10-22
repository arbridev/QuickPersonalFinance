//
//  CurrencyDataPersistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/6/23.
//

import CoreData

protocol CurrencyDataService: CoreDataPersistable {
    func save(item: LatestCurrencies) throws
    func load() throws -> LatestCurrencies?
    func delete() throws
}

/// Persistence service related to CurrencyData.
/// Every access goes through `performAndWait` because callers (e.g. `CurrencyConversionController`)
/// run outside the context's queue.
class CurrencyDataPersistence: CurrencyDataService {

    let moc: NSManagedObjectContext

    required init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func save(item: LatestCurrencies) throws {
        try moc.performAndWait {
            let request = NSFetchRequest<StoredCurrencyData>(entityName: "\(StoredCurrencyData.self)")
            if let fetched = try moc.fetch(request).first {
                fetched.lastUpdate = item.meta.lastUpdatedAt
                fetched.data = try Serializer.toData(item.data)
            } else {
                _ = try StoredCurrencyData.from(item, context: moc)
            }
            try saveOrRollback()
        }
    }

    func load() throws -> LatestCurrencies? {
        try moc.performAndWait {
            let request = NSFetchRequest<StoredCurrencyData>(entityName: "\(StoredCurrencyData.self)")
            return try moc.fetch(request).compactMap({ LatestCurrencies.from($0) }).first
        }
    }

    func delete() throws {
        try moc.performAndWait {
            let request = NSFetchRequest<StoredCurrencyData>(entityName: "\(StoredCurrencyData.self)")
            if let fetched = try moc.fetch(request).first {
                moc.delete(fetched)
            }
            try saveOrRollback()
        }
    }
}
