//
//  DataController.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 17/4/23.
//

import CoreData
import OSLog

/// Controller for data initialization
class DataController: ObservableObject {
    private(set) var container = NSPersistentContainer(name: "QuickPersonalFinance")
    @Published private(set) var loadError: Error?

    init(inMemory: Bool = false) {
        if inMemory || LaunchArguments.shared.contains(.testing) {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let storeURL = container.persistentStoreDescriptions.first?.url {
            do {
                try StoreMigrator.migrateStoreIfNeeded(at: storeURL)
            } catch {
                Logger.persistence.fault("Core Data migration failed: \(error.localizedDescription)")
                assertionFailure("Core Data migration failed: \(error)")
                loadError = error
                return
            }
        }
        container.loadPersistentStores { [weak self] _, error in
            guard let error else {
                return
            }
            Logger.persistence.fault("Core Data failed to load: \(error.localizedDescription)")
            assertionFailure("Core Data failed to load: \(error)")
            self?.loadError = error
        }
    }
}
