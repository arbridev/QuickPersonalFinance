//
//  Model+Persistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 17/4/23.
//

import CoreData

extension Income {
    static func from(_ origin: StoredIncome) -> Income {
        Income(
            id: origin.id ?? UUID(),
            name: origin.name ?? "",
            more: origin.more,
            grossValue: origin.grossValue,
            recurrence: Recurrence(rawValue: origin.recurrence ?? "")
        )
    }
}

extension StoredIncome {
    static func from(_ origin: Income, context: NSManagedObjectContext) -> StoredIncome {
        let destination = StoredIncome(context: context)
        destination.id = origin.id
        destination.name = origin.name
        destination.more = origin.more
        destination.grossValue = origin.grossValue
        destination.recurrence = origin.recurrence?.rawValue
        return destination
    }
}

extension Expense {
    static func from(_ origin: StoredExpense) -> Expense {
        Expense(
            id: origin.id ?? UUID(),
            name: origin.name ?? "",
            more: origin.more,
            grossValue: origin.grossValue,
            recurrence: Recurrence(rawValue: origin.recurrence ?? "")
        )
    }
}

extension StoredExpense {
    static func from(_ origin: Expense, context: NSManagedObjectContext) -> StoredExpense {
        let destination = StoredExpense(context: context)
        destination.id = origin.id
        destination.name = origin.name
        destination.more = origin.more
        destination.grossValue = origin.grossValue
        destination.recurrence = origin.recurrence?.rawValue
        return destination
    }
}

extension LatestCurrencies {
    static func from(_ origin: StoredCurrencyData) -> LatestCurrencies? {
        guard let lastUpdate = origin.lastUpdate,
                let data = origin.data
        else {
            return nil
        }
        let meta = Meta(lastUpdatedAt: lastUpdate)

        do {
            let decoder = JSONDecoder()
            let currencies = try decoder.decode([String: Currency].self, from: data)
            return LatestCurrencies(meta: meta, data: currencies)
        } catch {
            print(error)
        }
        return nil
    }
}

extension StoredCurrencyData {
    static func from(_ origin: LatestCurrencies, context: NSManagedObjectContext) -> StoredCurrencyData? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(origin.data)

            let destination = StoredCurrencyData(context: context)
            destination.lastUpdate = origin.meta.lastUpdatedAt
            destination.data = data
            return destination
        } catch {
            print(error)
        }
        return nil
    }
}
