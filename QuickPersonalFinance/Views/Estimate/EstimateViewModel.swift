//
//  EstimateViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/4/23.
//

import Foundation

extension EstimateView {

    @MainActor class ViewModel: ObservableObject {

        // MARK: Properties

        @Published private(set) var mainData: AppData?
        @Published private(set) var summary: EstimateSummary
        @Published var selectedRecurrence: Recurrence = .year {
            didSet {
                update()
                HapticsService().selectionFeedback()
            }
        }
        @Published var barChartData: [BarValue] = [BarValue]()
        @Published var isPresentingSettings = false {
            didSet {
                if !isPresentingSettings {
                    update()
                }
            }
        }
        @Published var isPresentingCurrencyConversion = false

        private let settings: SettingsService
        private let calculations: CalculationService

        // MARK: Initialization

        init(settings: SettingsService) {
            self.settings = settings
            calculations = Calculation(settings: settings)
            summary = EstimateSummary(
                incomeTotal: 0,
                expenseTotal: 0,
                balance: 0,
                recurrence: .year,
                currencyID: settings.currencyID
            )
        }

        // MARK: Behavior

        func input(mainData: AppData) {
            self.mainData = mainData
        }

        func update() {
            guard let mainData else {
                return
            }
            summary = EstimateSummary(
                financeData: mainData.financeData,
                recurrence: selectedRecurrence,
                currencyID: settings.currencyID,
                calculation: calculations
            )
            createChartData()
        }

        private func createChartData() {
            let barChartData = [
                BarValue(title: "estimate.table.income".localized, total: summary.incomeTotal),
                BarValue(title: "estimate.table.expense".localized, total: summary.expenseTotal)
            ]
            self.barChartData = barChartData
        }
    }

}

// MARK: - Bar value

extension EstimateView {
    struct BarValue {
        let title: String
        let total: Double
    }
}
