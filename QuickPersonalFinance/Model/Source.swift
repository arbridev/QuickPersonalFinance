//
//  Source.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 12/3/23.
//

import Foundation

protocol Source: Codable, Hashable, Identifiable {
    var id: UUID { get }
    var name: String { get }
    var more: String? { get }
    var grossValue: Decimal { get }
    var recurrence: Recurrence? { get }
    var firstPaymentDate: Date? { get }
    var lastPaymentDate: Date? { get }
}

extension Source {
    func nextPaymentDate(from now: Date = .now, calendar: Calendar = .current) -> Date? {
        PaymentSchedule.nextDate(
            first: firstPaymentDate,
            last: lastPaymentDate,
            recurrence: recurrence,
            from: now,
            calendar: calendar
        )
    }
}
