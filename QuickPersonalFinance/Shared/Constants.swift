//
//  Constants.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import Foundation
import ArkanaKeys
import ArkanaKeysInterfaces

struct Constant {
    static let monthsPerYearCount: Double = 12
    static let weeksPerMonthCount: Double = 4.34
    static let workHoursPerDay: Double = 8
    static let workDaysPerWeek: Double = 5
    static let defaultCurrencyID: String = "USD"
    static let secondaryCurrencyID: String = "EUR"
    static let maxLengthNameField = 30
    static let maxLengthMoreField = 50
    static let maxLengthValueField = 20
    static let maxLengthWorkHoursPerDayField = 5
    static let maxLengthWorkDaysPerWeekField = 4
    static let currencyRefreshInterval: TimeInterval = 60 * 2
    static let currencyAPIURL = secrets.currencyAPIURL
    static let currencyIDs = Locale.Currency.isoCurrencies.map({ $0.identifier })

    private static let secrets: ArkanaKeysEnvironmentProtocol = {
        #if DEBUG
        ArkanaKeys.Debug()
        #else
        ArkanaKeys.Release()
        #endif
    }()

    private init() {}
}
