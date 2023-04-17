//
//  DataController.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 17/4/23.
//

import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "QuickPersonalFinance")

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
