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
            recurrence: Recurrence.init(rawValue: origin.recurrence ?? "")
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
            recurrence: Recurrence.init(rawValue: origin.recurrence ?? "")
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
