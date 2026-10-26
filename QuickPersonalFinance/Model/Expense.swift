//
//  Expense.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/3/23.
//

import Foundation

struct Expense: Source {
    let id: UUID
    let name: String
    let more: String?
    let grossValue: Decimal
    let recurrence: Recurrence?
    let firstPaymentDate: Date?
    let lastPaymentDate: Date?

    init(
        id: UUID,
        name: String,
        more: String?,
        grossValue: Decimal,
        recurrence: Recurrence?,
        firstPaymentDate: Date? = nil,
        lastPaymentDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.more = more
        self.grossValue = grossValue
        self.recurrence = recurrence
        self.firstPaymentDate = firstPaymentDate
        self.lastPaymentDate = lastPaymentDate
    }
}
