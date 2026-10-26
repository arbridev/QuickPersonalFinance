//
//  EstimateSummary.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 22/10/26.
//

import Foundation

/// Totals of an estimate for a recurrence, with the texts shown and shared for them.
struct EstimateSummary {
    let incomeTotal: Decimal
    let expenseTotal: Decimal
    let balance: Decimal
    let recurrence: Recurrence
    let currencyID: String

    var balanceInfoMessage: String {
        String(
            format: "estimate.balance.info.message".localized,
            currencyID,
            recurrence.rawValue.localized
        )
    }

    var shareMessage: String {
        String(
            format: (balance > 0.0 ? "estimate.share.message.save" : "estimate.share.message.lose").localized,
            recurrence.rawValue.localized,
            incomeTotal.asCurrency(withID: currencyID),
            expenseTotal.asCurrency(withID: currencyID),
            balance.asCurrency(withID: currencyID),
            currencyID
        )
    }
}

extension EstimateSummary {
    init(
        financeData: FinanceData,
        recurrence: Recurrence,
        currencyID: String,
        calculation: CalculationService
    ) {
        self.init(
            incomeTotal: calculation.totalize(sources: financeData.incomes, to: recurrence),
            expenseTotal: calculation.totalize(sources: financeData.expenses, to: recurrence),
            balance: calculation.makeBalance(
                incomes: financeData.incomes,
                expenses: financeData.expenses,
                basedOn: recurrence
            ),
            recurrence: recurrence,
            currencyID: currencyID
        )
    }
}
