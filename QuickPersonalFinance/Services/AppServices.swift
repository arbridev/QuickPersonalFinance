//
//  AppServices.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 22/10/26.
//

import CoreData

/// Services shared by the screens, built once at the app root and passed down to view models.
struct AppServices {
    let settings: SettingsService
    let incomePersistence: any IncomePersistenceService
    let expensePersistence: any ExpensePersistenceService
    let currencyControl: any CurrencyControl
    let currencyIDs: [String]

    /// Services backed by the given context. When launched with the testing argument,
    /// currency conversion uses mock data instead of the external service.
    static func live(moc: NSManagedObjectContext) -> AppServices {
        let isTesting = LaunchArguments.shared.contains(.testing)
        let currencyControl: any CurrencyControl = isTesting ?
            MockCurrencyController() :
            CurrencyConversionController(
                persistenceService: CurrencyDataPersistence(moc: moc),
                externalService: ExternalCurrency(),
                userData: UserData()
            )
        return AppServices(
            settings: Settings(),
            incomePersistence: IncomePersistence(moc: moc),
            expensePersistence: ExpensePersistence(moc: moc),
            currencyControl: currencyControl,
            currencyIDs: isTesting ? MockData.currencyIDs : Constant.currencyIDs
        )
    }

    /// Services for SwiftUI previews, backed by an in-memory store seeded with mock data.
    static let preview: AppServices = {
        let moc = MockData.previewManagedObjectContext
        return AppServices(
            settings: Settings(),
            incomePersistence: IncomePersistence(moc: moc),
            expensePersistence: ExpensePersistence(moc: moc),
            currencyControl: MockCurrencyController(),
            currencyIDs: MockData.currencyIDs
        )
    }()
}
