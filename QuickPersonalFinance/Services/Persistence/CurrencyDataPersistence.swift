//
//  CurrencyDataPersistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/6/23.
//

import CoreData

protocol CurrencyDataService: CoreDataPersistable {
    func save(item: LatestCurrencies)
    func load() -> LatestCurrencies?
    func delete()
}

/// Persistence service related to CurrencyData.
/// Every access goes through `performAndWait` because callers (e.g. `CurrencyConversionController`)
/// run outside the context's queue.
class CurrencyDataPersistence: CurrencyDataService {

    let moc: NSManagedObjectContext

    required init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func save(item: LatestCurrencies) {
        moc.performAndWait {
            let request = NSFetchRequest<StoredCurrencyData>(entityName: "\(StoredCurrencyData.self)")
            if let fetched = try? moc.fetch(request).first {
                fetched.lastUpdate = item.meta.lastUpdatedAt
                fetched.data = try? Serializer.toData(item.data)
            } else {
                _ = StoredCurrencyData.from(item, context: moc)
            }
            do {
                try moc.save()
            } catch {
                print(error)
            }
        }
    }

    func load() -> LatestCurrencies? {
        moc.performAndWait {
            let request = NSFetchRequest<StoredCurrencyData>(entityName: "\(StoredCurrencyData.self)")
            let fetched = try? moc.fetch(request)
            return fetched?.compactMap({ LatestCurrencies.from($0) }).first
        }
    }

    func delete() {
        moc.performAndWait {
            let request = NSFetchRequest<StoredCurrencyData>(entityName: "\(StoredCurrencyData.self)")
            if let fetched = try? moc.fetch(request).first {
                moc.delete(fetched)
            }
            try? moc.save()
        }
    }
}
