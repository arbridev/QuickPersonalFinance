//
//  MockData.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import Foundation

struct MockData {
    private init() {}
    static let income1 = Income(
        name: "income1",
        more: "more",
        grossValue: 20.0,
        recurrence: .hour
    )
    static let income2 = Income(
        name: "income2",
        more: "more",
        grossValue: 120.0,
        recurrence: .week
    )
    static let expense1 = Expense(
        name: "expense1",
        more: "more",
        grossValue: 10.0,
        recurrence: .hour
    )
    static let expense2 = Expense(
        name: "expense2",
        more: "more",
        grossValue: 70.0,
        recurrence: .week
    )
}
