//
//  SettingsService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 27/4/23.
//

import Foundation

protocol SettingsService {
    var workHoursPerDay: Double { get set }
    var workDaysPerWeek: Double { get set }
    var currencyID: String { get set }
    init(persistence: UserDefaults)
}

/// Persistence service related to the app settings
struct Settings: SettingsService {

    // MARK: Nested types

    enum StorageKey: String {
        case workHoursPerDay, workDaysPerWeek, currencyID
    }

    // MARK: Properties

    let persistence: UserDefaults
    
    var workHoursPerDay: Double {
        get {
            let value = persistence.double(forKey: StorageKey.workHoursPerDay.rawValue)
            return value > 0.0 ? value : Constant.workHoursPerDay
        }
        set {
            persistence.set(newValue, forKey: StorageKey.workHoursPerDay.rawValue)
        }
    }

    var workDaysPerWeek: Double {
        get {
            let value = persistence.double(forKey: StorageKey.workDaysPerWeek.rawValue)
            return value > 0.0 ? value : Constant.workDaysPerWeek
        }
        set {
            persistence.set(newValue, forKey: StorageKey.workDaysPerWeek.rawValue)
        }
    }

    var currencyID: String {
        get {
            let value = persistence.string(forKey: StorageKey.currencyID.rawValue)
            return value ??
            Locale.current.currency?.identifier ??
            Constant.defaultCurrencyID
        }
        set {
            persistence.set(newValue, forKey: StorageKey.currencyID.rawValue)
        }
    }

    // MARK: Initialization

    init(persistence: UserDefaults = UserDefaults.standard) {
        self.persistence = persistence
    }
}
