//
//  ExportPDFView+Report.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 13/5/23.
//

import SwiftUI
import Charts

extension ExportPDFView {
    // MARK: - ReportSourcesView
    struct ReportSourcesView: View {
        let contentWidth: Double
        let contentHeight: Double
        let horizontalMargins: Double
        let verticalMargins: Double

        var mainTitle: String?
        var sectionTitles: [String?]
        var sources: [[any Source]?]

        var body: some View {
            HStack {
                Spacer(minLength: horizontalMargins / 2)
                VStack {
                    // MARK: Main title
                    if let mainTitle {
                        Text(LocalizedStringKey(mainTitle))
                            .font(Font.Report.mainTitle)
                            .foregroundColor(.black)
                            .padding()

                        Divider()
                    }

                    // MARK: Sections
                    ForEach(0..<sectionTitles.count, id: \.self) { index in
                        if let sectionTitle = sectionTitles[index] {
                            HStack {
                                Text(LocalizedStringKey(sectionTitle))
                                    .font(Font.Report.title1)
                                    .padding(.bottom, 10)
                                Spacer()
                            }
                        }

                        if let sectionSources = sources[index] {
                            VStack {
                                ForEach(sectionSources, id: \.id) { source in
                                    HStack {
                                        Text(source.name)
                                            .font(Font.Report.standard)
                                        if let recurrence = source.recurrence {
                                            Text(recurrence.rawValue)
                                                .font(Font.Report.info)
                                        }
                                        Spacer()
                                        Text(source.grossValue.asCurrency)
                                            .font(Font.Report.standard)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    ReportPageFooter()
                }
                .frame(width: contentWidth, height: contentHeight, alignment: .center)
            }
        }

        init(mainTitle: String?, sectionTitles: [String?], sources: [[any Source]?]) {
            let pdfDpi: Double = 72.0
            let letterWidth: Double = 8.5 * pdfDpi
            let letterHeight: Double = 11 * pdfDpi
            horizontalMargins = 0.75 * 2 * pdfDpi
            verticalMargins = 0.75 * 2 * pdfDpi
            contentWidth = letterWidth - horizontalMargins
            contentHeight = letterHeight - verticalMargins
            self.mainTitle = mainTitle
            self.sectionTitles = sectionTitles
            self.sources = sources
        }
    }

    // MARK: - ReportEstimateView
    struct ReportEstimateView: View {
        let contentWidth: Double
        let contentHeight: Double
        let horizontalMargins: Double
        let verticalMargins: Double

        var incomeTotal: Double
        var expenseTotal: Double
        var balance: Double
        var recurrence: Recurrence

        var currencyCode: String {
            Locale.current.currency?.identifier ?? "USD"
        }

        var shareMessage: String {
            if balance > 0.0 {
                return String(
                    format: "estimate.share.message.save".localized,
                    recurrence.rawValue.localized,
                    incomeTotal.asCurrency,
                    expenseTotal.asCurrency,
                    balance.asCurrency,
                    currencyCode
                )
            } else {
                return String(
                    format: "estimate.share.message.lose".localized,
                    recurrence.rawValue.localized,
                    incomeTotal.asCurrency,
                    expenseTotal.asCurrency,
                    balance.asCurrency,
                    currencyCode
                )
            }
        }

        var body: some View {
            HStack {
                Spacer(minLength: horizontalMargins / 2)
                VStack {
                    // MARK: Title
                    HStack {
                        Text("estimate.title")
                            .font(Font.Report.title1)
                            .padding(.bottom, 10)
                        Spacer()
                    }

                    Divider()

                    Group {
                        VStack {
                            HStack {
                                Text("estimate.table.income")
                                Spacer()
                                Text(incomeTotal.asCurrency)
                            }
                        }

                        VStack {
                            HStack {
                                Text("estimate.table.expense")
                                Spacer()
                                Text(expenseTotal.asCurrency)
                            }
                        }

                        Divider()

                        VStack {
                            HStack {
                                Text("estimate.table.total")
                                Spacer()
                                Text(balance.asCurrency)
                            }
                        }

                        Text(shareMessage)
                            .font(Font.Report.info)
                            .padding(.top, 8)
                    }

                    Divider()
                        .padding(.vertical)

                    ReportChartView(incomeTotal: incomeTotal, expenseTotal: expenseTotal)

                    Spacer()

                    ReportPageFooter()
                }
                .frame(width: contentWidth, height: contentHeight, alignment: .center)
                .font(Font.Report.standard)
            }
        }

        init(
            incomeTotal: Double,
            expenseTotal: Double,
            balance: Double,
            recurrence: Recurrence
        ) {
            let pdfDpi: Double = 72.0
            let letterWidth: Double = 8.5 * pdfDpi
            let letterHeight: Double = 11 * pdfDpi
            horizontalMargins = 0.75 * 2 * pdfDpi
            verticalMargins = 0.75 * 2 * pdfDpi
            contentWidth = letterWidth - horizontalMargins
            contentHeight = letterHeight - verticalMargins
            self.incomeTotal = incomeTotal
            self.expenseTotal = expenseTotal
            self.balance = balance
            self.recurrence = recurrence
        }
    }

    // MARK: - ReportChartView
    struct ReportChartView: View {
        struct BarValue {
            let title: String
            let total: Double
        }

        let contentWidth: Double
        let contentHeight: Double
        let horizontalMargins: Double
        let verticalMargins: Double
        let barChartColors: [Color] = [.Palette.incomeTable, .Palette.expenseTable]

        var incomeTotal: Double
        var expenseTotal: Double
        var barChartData: [BarValue] = [BarValue]()

        var body: some View {
            HStack {
                VStack {
                    // MARK: Chart
                    Chart {
                        ForEach(barChartData, id: \.title) { barValue in
                            BarMark(
                                x: .value("estimate.chart.source".localized, barValue.title),
                                y: .value("estimate.table.total".localized, barValue.total)
                            )
                            .foregroundStyle(by: .value("estimate.chart.source".localized, barValue.title))
                        }
                    }
                    .chartForegroundStyleScale(
                        domain: [
                            "estimate.table.income".localized,
                            "estimate.table.expense".localized],
                        range: barChartColors
                    )
                    .frame(width: contentWidth / 2, height: contentHeight / 2, alignment: .center)

                    Spacer()
                }
                .frame(width: contentWidth / 2, height: contentHeight / 2, alignment: .center)
            }
        }

        init(
            incomeTotal: Double,
            expenseTotal: Double
        ) {
            let pdfDpi: Double = 72.0
            let letterWidth: Double = 8.5 * pdfDpi
            let letterHeight: Double = 11 * pdfDpi
            horizontalMargins = 0.75 * 2 * pdfDpi
            verticalMargins = 0.75 * 2 * pdfDpi
            contentWidth = letterWidth - horizontalMargins
            contentHeight = letterHeight - verticalMargins
            self.incomeTotal = incomeTotal
            self.expenseTotal = expenseTotal
            self.barChartData = createChartData()
        }

        private func createChartData() -> [BarValue] {
            let barChartData = [
                BarValue(title: "estimate.table.income".localized, total: incomeTotal),
                BarValue(title: "estimate.table.expense".localized, total: expenseTotal)
            ]
            return barChartData
        }
    }

    struct ReportPageFooter: View {
        var body: some View {
            VStack {
                Text("QuickPersonalFinance ™")
            }
            .frame(width: nil, height: 40, alignment: .center)
            .font(Font.Report.trademark)
        }
    }

    // MARK: Creation methods

    func createSources(
        mainTitle: String?,
        sectionTitles: [String?],
        sources: [[any Source]?]
    ) -> some View {
        ReportSourcesView(mainTitle: mainTitle, sectionTitles: sectionTitles, sources: sources)
    }

    func createEstimate(
        incomeTotal: Double,
        expenseTotal: Double,
        balance: Double,
        recurrence: Recurrence
    ) -> some View {
        ReportEstimateView(
            incomeTotal: incomeTotal,
            expenseTotal: expenseTotal,
            balance: balance,
            recurrence: recurrence
        )
    }
}
