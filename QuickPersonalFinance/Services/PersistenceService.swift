//
//  PersistenceService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/4/23.
//

import CoreData

protocol PersistenceService {
    associatedtype PersistentType
    func save(item: PersistentType)
    func loadAll() -> [PersistentType]
    func load(itemWithID: UUID) -> PersistentType?
    func update(item: PersistentType)
    func delete(item: PersistentType)
    func delete(items: [PersistentType])
}

protocol CoreDataPersistable {
    var moc: NSManagedObjectContext { get }
    init(moc: NSManagedObjectContext)
}
