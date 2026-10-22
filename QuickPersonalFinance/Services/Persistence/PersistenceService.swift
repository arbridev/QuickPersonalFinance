//
//  PersistenceService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/4/23.
//

import CoreData
import OSLog

protocol PersistenceService {
    associatedtype PersistentType
    func save(item: PersistentType) throws
    func loadAll() throws -> [PersistentType]
    func load(itemWithID: UUID) throws -> PersistentType?
    func update(item: PersistentType) throws
    func delete(item: PersistentType) throws
    func delete(items: [PersistentType]) throws
}

protocol CoreDataPersistable {
    var moc: NSManagedObjectContext { get }
    init(moc: NSManagedObjectContext)
}

enum PersistenceError: LocalizedError {
    case itemNotFound

    var errorDescription: String? {
        "error.unknown".localized
    }
}

extension CoreDataPersistable {
    /// Saves pending changes, discarding them if the save fails so the context
    /// doesn't keep objects that never reached the store.
    func saveOrRollback() throws {
        guard moc.hasChanges else {
            return
        }
        do {
            try moc.save()
        } catch {
            moc.rollback()
            throw error
        }
    }
}

extension Logger {
    static let persistence = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "QuickPersonalFinance",
        category: "persistence"
    )
}
