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
    let grossValue: Double
    let recurrence: Recurrence?
}
