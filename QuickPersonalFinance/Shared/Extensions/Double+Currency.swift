//
//  Double+Currency.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import Foundation

extension Decimal {
    private static let moneyLocale = Locale(identifier: "en_US_POSIX")

    /// Parses an amount from the decimal pad.
    ///
    /// `Decimal(string:locale:)` returns the digits before a separator it does not
    /// recognize, so "10,50" becomes 10. The pad inserts "." or "," depending on
    /// the locale, and either one is a fractional amount here.
    static func parseMoney(_ text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let separators = Set([Locale.current.decimalSeparator ?? ".", ".", ","])
        let separatorCount = trimmed.reduce(into: 0) { count, character in
            if separators.contains(String(character)) {
                count += 1
            }
        }
        guard separatorCount <= 1 else { return nil }

        var normalized = trimmed
        for separator in separators where separator != "." {
            normalized = normalized.replacingOccurrences(of: separator, with: ".")
        }

        let formatter = NumberFormatter()
        formatter.locale = moneyLocale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.usesGroupingSeparator = false
        return (formatter.number(from: normalized) as? NSDecimalNumber)?.decimalValue
    }

    /// Text for a value field, using the separator the decimal pad inserts.
    var moneyText: String {
        let canonical = NSDecimalNumber(decimal: self).stringValue
        guard let separator = Locale.current.decimalSeparator, separator != "." else {
            return canonical
        }
        return canonical.replacingOccurrences(of: ".", with: separator)
    }

    /// Charts plot binary floating point. This is only for display.
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    func asCurrency(withID id: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        if let id {
            formatter.currencyCode = id
        }
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? moneyText
    }
}
