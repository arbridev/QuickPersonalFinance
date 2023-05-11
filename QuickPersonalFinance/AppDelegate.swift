//
//  AppDelegate.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/5/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("Documents directory:", URL.documentsDirectory)
        FirebaseApp.configure()
        return true
    }
}
