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
    init(persistence: UserDefaults)
}

struct Settings: SettingsService {
    enum StorageKey: String {
        case workHoursPerDay, workDaysPerWeek
    }

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

    init(persistence: UserDefaults) {
        self.persistence = persistence
    }
}
