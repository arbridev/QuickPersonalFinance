//
//  Recurrence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/3/23.
//

import Foundation

enum Recurrence: String, Codable {
    case hour = "hour", day = "day", week = "week", month = "month", year = "year"
}

extension Recurrence: CaseIterable, Comparable {
    var order: Int {
        switch self {
            case .hour:
                return 0
            case .day:
                return 1
            case .week:
                return 2
            case .month:
                return 3
            case .year:
                return 4
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.order == rhs.order
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
       return lhs.order < rhs.order
    }
}
