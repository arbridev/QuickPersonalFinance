//
//  Recurrence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/3/23.
//

import Foundation

enum Recurrence: String, Codable {
    case hour, day, week, month, year
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

    /// Stand-in anchor when no first payment has been saved. Week, month, and year use the
    /// first day of the current period. Day and hour use the start of the current day or hour.
    func placeholderFirstPaymentDate(from now: Date = .now, calendar: Calendar = .current) -> Date {
        calendar.dateInterval(of: steppingComponent, for: now)?.start ?? now
    }

    /// Date-only recurrences ignore the time of day. Hourly payments keep it.
    func normalized(_ date: Date, calendar: Calendar = .current) -> Date {
        if self == .hour {
            return date
        }
        return calendar.startOfDay(for: date)
    }

    /// The next occurrence on or after `reference`, counted from the original anchor.
    /// Adding months or years to that anchor keeps a 31st on the 31st, and shorter
    /// months clamp to their last day instead of drifting forward.
    func nextDate(onOrAfter reference: Date, from anchor: Date, calendar: Calendar = .current) -> Date? {
        let start = normalized(anchor, calendar: calendar)
        let boundary = normalized(reference, calendar: calendar)
        if start >= boundary {
            return start
        }

        let component = steppingComponent
        let elapsed = calendar.dateComponents([component], from: start, to: boundary).value(for: component) ?? 0
        let count = max(elapsed, 0)
        guard let stepped = calendar.date(byAdding: component, value: count, to: start) else {
            return nil
        }
        if stepped >= boundary {
            return stepped
        }
        return calendar.date(byAdding: component, value: count + 1, to: start)
    }

    private var steppingComponent: Calendar.Component {
        switch self {
            case .hour:
                return .hour
            case .day:
                return .day
            case .week:
                return .weekOfYear
            case .month:
                return .month
            case .year:
                return .year
        }
    }
}

enum PaymentSchedule {
    static func nextDate(
        first: Date?,
        last: Date?,
        recurrence: Recurrence?,
        from now: Date = .now,
        calendar: Calendar = .current
    ) -> Date? {
        guard let recurrence else {
            return nil
        }
        let anchor = first ?? recurrence.placeholderFirstPaymentDate(from: now, calendar: calendar)
        guard let next = recurrence.nextDate(onOrAfter: now, from: anchor, calendar: calendar) else {
            return nil
        }
        if let last, next > recurrence.normalized(last, calendar: calendar) {
            return nil
        }
        return next
    }

    static func format(_ date: Date, recurrence: Recurrence) -> String {
        date.formatted(
            date: .abbreviated,
            time: recurrence == .hour ? .shortened : .omitted
        )
    }
}

/// Dates chosen on the create and edit forms, before they are stored.
struct PaymentDateSelection {
    var firstPaymentDate: Date
    /// True while `firstPaymentDate` is only the period placeholder and must not be saved.
    var firstPaymentDateIsPlaceholder: Bool
    var includesLastPayment: Bool
    var lastPaymentDate: Date
    var recurrence: Recurrence

    init(
        firstPaymentDate: Date = Date(),
        firstPaymentDateIsPlaceholder: Bool = false,
        includesLastPayment: Bool = false,
        lastPaymentDate: Date = Date(),
        recurrence: Recurrence
    ) {
        self.firstPaymentDate = firstPaymentDate
        self.firstPaymentDateIsPlaceholder = firstPaymentDateIsPlaceholder
        self.includesLastPayment = includesLastPayment
        self.lastPaymentDate = lastPaymentDate
        self.recurrence = recurrence
    }

    init(
        first: Date?,
        last: Date?,
        recurrence: Recurrence,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let start = first ?? recurrence.placeholderFirstPaymentDate(from: now, calendar: calendar)
        self.init(
            firstPaymentDate: start,
            firstPaymentDateIsPlaceholder: first == nil,
            includesLastPayment: last != nil,
            lastPaymentDate: last ?? start,
            recurrence: recurrence
        )
    }

    func storedDates(calendar: Calendar = .current) -> (first: Date, last: Date?) {
        let first = recurrence.normalized(firstPaymentDate, calendar: calendar)
        guard includesLastPayment else {
            return (first, nil)
        }
        return (first, recurrence.normalized(lastPaymentDate, calendar: calendar))
    }

    /// Dates to write. A placeholder first payment stays nil.
    func persistedDates(calendar: Calendar = .current) -> (first: Date?, last: Date?) {
        let stored = storedDates(calendar: calendar)
        guard firstPaymentDateIsPlaceholder else {
            return (stored.first, stored.last)
        }
        return (nil, stored.last)
    }

    func isValid(calendar: Calendar = .current) -> Bool {
        let stored = storedDates(calendar: calendar)
        guard let last = stored.last else {
            return true
        }
        return last >= stored.first
    }

    func nextPaymentDate(from now: Date = .now, calendar: Calendar = .current) -> Date? {
        guard isValid(calendar: calendar) else {
            return nil
        }
        let stored = storedDates(calendar: calendar)
        return PaymentSchedule.nextDate(
            first: stored.first,
            last: stored.last,
            recurrence: recurrence,
            from: now,
            calendar: calendar
        )
    }

    var validationMessage: String? {
        guard isValid() else {
            return "action.validation.error.last.payment".localized
        }
        return nil
    }
}
