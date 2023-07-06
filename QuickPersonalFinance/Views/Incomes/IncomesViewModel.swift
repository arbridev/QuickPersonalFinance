//
//  IncomesViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import CoreData

extension IncomesView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published var mainData: AppData?
        @Published var isPresentingCreateAction = false
        @Published var isPresentingEditAction = false
        @Published var selectedItem: Income? {
            didSet {
                isPresentingEditAction.toggle()
            }
        }

        private let settings: SettingsService
        var moc: NSManagedObjectContext?
        var persistenceService: (any IncomePersistenceService)?
        var currencyID: String {
            settings.currencyID
        }

        init() {
            settings = Settings()
        }

        // MARK: Behavior

        func input(mainData: AppData, moc: NSManagedObjectContext) {
            self.mainData = mainData
            self.persistenceService = IncomePersistence(moc: moc)
        }

        func deleteItems(at offsets: IndexSet) {
            guard let oldData = mainData else {
                return
            }
            var incomes = oldData.financeData.incomes
            incomes.remove(atOffsets: offsets)

            let forDeletion = oldData.financeData.incomes.difference(from: incomes)

            let financeData = FinanceData(
                incomes: incomes,
                expenses: oldData.financeData.expenses
            )
            mainData?.financeData = financeData
            
            persistenceService?.delete(items: forDeletion)
            HapticsService().notificationFeedback(.success)
        }
    }

}
