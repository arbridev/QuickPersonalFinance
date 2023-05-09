//
//  QuickPersonalFinanceApp.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI
import FirebaseCore

@main
struct QuickPersonalFinanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
