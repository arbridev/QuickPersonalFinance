//
//  Model+Persistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 17/4/23.
//

import CoreData
import OSLog

extension StoredSource {
    var money: Decimal {
        get { grossValue?.decimalValue ?? 0 }
        set { grossValue = NSDecimalNumber(decimal: newValue) }
    }
}

extension Income {
    /// Returns nil for rows without an id, since a new id would break later updates and deletes.
    static func from(_ origin: StoredIncome) -> Income? {
        guard let id = origin.id else {
            Logger.persistence.error("Skipping stored income without id")
            return nil
        }
        return Income(
            id: id,
            name: origin.name ?? "",
            more: origin.more,
            grossValue: origin.money,
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
        destination.money = origin.grossValue
        destination.recurrence = origin.recurrence?.rawValue
        return destination
    }
}

extension Expense {
    /// Returns nil for rows without an id, since a new id would break later updates and deletes.
    static func from(_ origin: StoredExpense) -> Expense? {
        guard let id = origin.id else {
            Logger.persistence.error("Skipping stored expense without id")
            return nil
        }
        return Expense(
            id: id,
            name: origin.name ?? "",
            more: origin.more,
            grossValue: origin.money,
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
        destination.money = origin.grossValue
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
            let currencies: [String: Currency] = try Serializer.fromData(data)
            return LatestCurrencies(meta: meta, data: currencies)
        } catch {
            Logger.persistence.error("Could not decode stored currencies: \(error.localizedDescription)")
        }
        return nil
    }
}

extension StoredCurrencyData {
    static func from(_ origin: LatestCurrencies, context: NSManagedObjectContext) throws -> StoredCurrencyData {
        let data = try Serializer.toData(origin.data)

        let destination = StoredCurrencyData(context: context)
        destination.lastUpdate = origin.meta.lastUpdatedAt
        destination.data = data
        return destination
    }
}
