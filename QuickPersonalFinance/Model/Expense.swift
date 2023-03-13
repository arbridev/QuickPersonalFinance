//
//  Expense.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/3/23.
//

import Foundation

struct Expense: Source {
    let netValue: Double
    let recurrence: Recurrence?
}
