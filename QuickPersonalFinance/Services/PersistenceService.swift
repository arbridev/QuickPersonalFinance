//
//  PersistenceService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 19/4/23.
//

import CoreData

protocol PersistenceService {
    associatedtype T
    func save(item: T)
    func loadAll() -> [T]
    func load(itemWithID: UUID) -> T?
    func update(item: T)
    func delete(item: T)
    func delete(items: [T])
}

protocol CoreDataPersistable {
    var moc: NSManagedObjectContext { get }
    init(moc: NSManagedObjectContext)
}
