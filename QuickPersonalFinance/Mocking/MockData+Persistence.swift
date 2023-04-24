//
//  MockData+Persistence.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 24/4/23.
//

import CoreData

extension MockData {
    static var previewManagedObjectContext: NSManagedObjectContext = {
        let dataController = DataController(inMemory: true)
        let context = dataController.container.viewContext
        let incomePersistence = IncomePersistence(moc: context)
        let expensePersistence = ExpensePersistence(moc: context)
        incomePersistence.save(item: MockData.income1)
        expensePersistence.save(item: MockData.expense1)
        return context
    }()
}
