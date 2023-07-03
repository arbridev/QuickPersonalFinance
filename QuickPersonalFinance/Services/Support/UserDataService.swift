//
//  UserDataService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 2/7/23.
//

import Foundation

protocol UserDataService {
    var lastCurrencyUpdate: Date? { get set }
    init(persistence: UserDefaults)
}

/// Persistence service related to the user's data
struct UserData: UserDataService {

    // MARK: Nested types

    enum StorageKey: String {
        case lastCurrencyUpdate
    }

    // MARK: Properties

    let persistence: UserDefaults

    var lastCurrencyUpdate: Date? {
        get {
            let value = persistence.object(forKey: StorageKey.lastCurrencyUpdate.rawValue)
            return value as? Date
        }
        set {
            persistence.set(newValue, forKey: StorageKey.lastCurrencyUpdate.rawValue)
        }
    }

    // MARK: Initialization

    init(persistence: UserDefaults = UserDefaults.standard) {
        if LaunchArguments.shared.contains(.testing) {
            self.persistence = UserDefaults(suiteName: "test-\(Self.self)") ??
            UserDefaults.standard
            return
        }
        self.persistence = persistence
    }
}
