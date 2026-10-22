//
//  ContentViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 20/4/23.
//

import Foundation
import OSLog

extension ContentView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var mainData: AppData?

        private let incomePersistenceService: any IncomePersistenceService
        private let expensePersistenceService: any ExpensePersistenceService

        // MARK: Initialization

        init(services: AppServices) {
            incomePersistenceService = services.incomePersistence
            expensePersistenceService = services.expensePersistence
        }

        // MARK: Behavior

        func input(mainData: AppData) {
            self.mainData = mainData
            do {
                let financeData = FinanceData(
                    incomes: try incomePersistenceService.loadAll(),
                    expenses: try expensePersistenceService.loadAll()
                )
                self.mainData?.financeData = financeData
            } catch {
                Logger.persistence.error("Could not load finance data: \(error.localizedDescription)")
            }
        }
    }

}
