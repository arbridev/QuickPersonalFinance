//
//  QuickPersonalFinanceApp.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

@main
struct QuickPersonalFinanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dataController: DataController
    private let services: AppServices

    var body: some Scene {
        WindowGroup {
            if dataController.loadError == nil {
                ContentView(services: services)
            } else {
                EmptyContentView(title: "error.store.title", message: "error.store.message")
            }
        }
    }

    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
        services = .live(moc: dataController.container.viewContext)
    }
}
