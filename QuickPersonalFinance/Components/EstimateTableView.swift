//
//  EstimateTableView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 22/10/26.
//

import SwiftUI

/// Income, expense and balance rows of an estimate.
struct EstimateTableView: View {
    let summary: EstimateSummary

    var body: some View {
        VStack {
            HStack {
                Text("estimate.table.income")
                Spacer()
                Text("\(summary.incomeTotal.asCurrency(withID: summary.currencyID))")
                    .underline(true, color: .Palette.incomeAccent)
            }
            .padding(.top)
            .padding(.horizontal)
            .font(.app(size: 18))

            HStack {
                Text("estimate.table.expense")
                Spacer()
                Text("\(summary.expenseTotal.asCurrency(withID: summary.currencyID))")
                    .underline(true, color: .Palette.expenseAccent)
            }
            .padding(.top, 6)
            .padding(.horizontal)
            .font(.app(size: 18))

            Divider()
                .overlay(Color.Palette.dividerSecondary)
                .padding(.top)
                .padding(.horizontal)

            HStack {
                Text("estimate.table.total")
                Spacer()
                Text("\(summary.balance.asCurrency(withID: summary.currencyID))")
                    .underline(true, color: .Palette.estimateAccent)
            }
            .padding(.top)
            .padding(.horizontal)
            .font(.app(size: 20))

            HStack {
                Spacer()
                Text(summary.balanceInfoMessage)
                    .font(.App.info)
            }
            .padding(.horizontal)
        }
    }
}

struct EstimateTableView_Previews: PreviewProvider {
    static var previews: some View {
        EstimateTableView(
            summary: EstimateSummary(
                incomeTotal: 1200,
                expenseTotal: 800,
                balance: 400,
                recurrence: .month,
                currencyID: Constant.defaultCurrencyID
            )
        )
    }
}
