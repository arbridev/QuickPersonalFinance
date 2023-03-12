//
//  Expense.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/3/23.
//

import Foundation

struct Expense: Codable, Hashable {
    let netValue: Double
    let isRecurring: Bool
}
