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
        id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0000000000A1")!,
        name: "income1",
        more: "more",
        grossValue: 20.0,
        recurrence: .hour
    )
    static let income2 = Income(
        id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0000000000A2")!,
        name: "income2",
        more: "more",
        grossValue: 120.0,
        recurrence: .week
    )
    static let expense1 = Expense(
        id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0000000000E1")!,
        name: "expense1",
        more: "more",
        grossValue: 10.0,
        recurrence: .hour
    )
    static let expense2 = Expense(
        id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0000000000E2")!,
        name: "expense2",
        more: "more",
        grossValue: 70.0,
        recurrence: .week
    )
    static let latestCurrencies: LatestCurrencies = MockingHelper.parseJSON(
        fromFileWithName: "example"
    )
}
