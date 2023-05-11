//
//  ExportPDFView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/5/23.
//

import SwiftUI
import Charts

/// Reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-a-swiftui-view-to-a-pdf
@MainActor
struct ExportPDFView: View {
    @EnvironmentObject private var mainData: AppData
    var recurrence: Recurrence
    @State private var calculations: CalculationService?
    @State private var incomeTotal: Double?
    @State private var expenseTotal: Double?
    @State private var balance: Double?

    var body: some View {
        ShareLink("Export PDF", item: render())
            .onAppear {
                calculations = Calculation(
                    incomes: mainData.financeData.incomes,
                    expenses: mainData.financeData.expenses
                )
                incomeTotal = calculations!.totalize(sources: mainData.financeData.incomes, to: recurrence)
                expenseTotal = calculations!.totalize(sources: mainData.financeData.expenses, to: recurrence)
                balance = (incomeTotal ?? 0.0) - (expenseTotal ?? 0.0)
            }
    }

    func render() -> URL {
        let incomesURL = subrender(
            fileName: "incomes-1.pdf",
            content: createSources(
                mainTitle: nil,
                sectionTitle: nil,
                sources: mainData.financeData.incomes
            )
        )
        let expensesURL = subrender(
            fileName: "expenses-1.pdf",
            content: createSources(
                mainTitle: nil,
                sectionTitle: nil,
                sources: mainData.financeData.expenses
            )
        )
        let estimateURL = subrender(
            fileName: "estimate-1.pdf",
            content: createEstimate(
                incomeTotal: incomeTotal ?? 0.0,
                expenseTotal: expenseTotal ?? 0.0,
                balance: balance ?? 0.0
            )
        )
        let chartURL = subrender(
            fileName: "chart.pdf",
            content: createChart(
                incomeTotal: incomeTotal ?? 0.0,
                expenseTotal: expenseTotal ?? 0.0
            )
        )
        return chartURL
    }

    func subrender(fileName: String, content: some View) -> URL {
        let url = URL.documentsDirectory.appending(path: fileName)
        let pdfDpi: Double = 72.0
        let letterWidth = 8.5 * pdfDpi
        let letterHeight = 11 * pdfDpi
        let renderer = ImageRenderer(
            content: content
        )

        renderer.render { _, renderer in
            var box = CGRect(x: 0, y: 0, width: letterWidth, height: letterHeight)

            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }

            pdfContext.beginPDFPage(nil)

            renderer(pdfContext)

            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }

        return url
    }

    init(recurrence: Recurrence) {
        self.recurrence = recurrence
    }
}

extension ExportPDFView {
    struct ReportSourcesView: View {
        let contentWidth: Double
        let contentHeight: Double
        let horizontalMargins: Double
        let verticalMargins: Double

        var mainTitle: String?
        var sectionTitle: String?
        var sources: [any Source]

        var body: some View {
            HStack {
                Spacer(minLength: horizontalMargins / 2)
                VStack {
                    // MARK: Title
                    if let mainTitle {
                        Text(mainTitle)
                                .font(.largeTitle)
                                .foregroundColor(.black)
                                .padding()

                        Divider()
                    }

                    // MARK: Sources
                    if let sectionTitle {
                        HStack {
                            Text(sectionTitle)
                                .font(.title)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                    }

                    VStack {
                        ForEach(sources, id: \.id) { source in
                            HStack {
                                Text(source.name)
                                    .font(.body)
                                Text(source.recurrence?.rawValue ?? "")
                                    .font(.caption)
                                Spacer()
                                Text(source.grossValue.asCurrency)
                            }
                        }
                    }

                    Spacer()
                }
                .frame(width: contentWidth, height: contentHeight, alignment: .center)
            }
        }

        init(mainTitle: String?, sectionTitle: String?, sources: [any Source]) {
            let pdfDpi: Double = 72.0
            let letterWidth: Double = 8.5 * pdfDpi
            let letterHeight: Double = 11 * pdfDpi
            horizontalMargins = 0.75 * 2 * pdfDpi
            verticalMargins = 0.75 * 2 * pdfDpi
            contentWidth = letterWidth - horizontalMargins
            contentHeight = letterHeight - verticalMargins
            self.mainTitle = mainTitle
            self.sectionTitle = sectionTitle
            self.sources = sources
        }
    }

    struct ReportEstimateView: View {
        let contentWidth: Double
        let contentHeight: Double
        let horizontalMargins: Double
        let verticalMargins: Double

        var incomeTotal: Double
        var expenseTotal: Double
        var balance: Double

        var body: some View {
            HStack {
                Spacer(minLength: horizontalMargins / 2)
                VStack {
                    // MARK: Title
                    HStack {
                        Text("Estimate")
                            .font(.title)
                            .padding(.bottom, 10)
                        Spacer()
                    }

                    Divider()

                    VStack {
                        HStack {
                            Text("Total income")
                                .font(.body)
                            Spacer()
                            Text(incomeTotal.asCurrency)
                        }
                    }

                    VStack {
                        HStack {
                            Text("Total expense")
                                .font(.body)
                            Spacer()
                            Text(expenseTotal.asCurrency)
                        }
                    }

                    Divider()

                    VStack {
                        HStack {
                            Text("Balance")
                                .font(.body)
                            Spacer()
                            Text(balance.asCurrency)
                        }
                    }

                    Spacer()
                }
                .frame(width: contentWidth, height: contentHeight, alignment: .center)
            }
        }

        init(
            incomeTotal: Double,
            expenseTotal: Double,
            balance: Double
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
        }
    }
    
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
                Spacer(minLength: horizontalMargins / 2)
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
                    .frame(width: contentWidth, height: contentHeight - 100.0, alignment: .center)

                    Spacer()
                }
                .frame(width: contentWidth, height: contentHeight, alignment: .center)
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

    func createSources(
        mainTitle: String?,
        sectionTitle: String?,
        sources: [any Source]
    ) -> some View {
        ReportSourcesView(mainTitle: mainTitle, sectionTitle: sectionTitle, sources: sources)
    }

    func createEstimate(
        incomeTotal: Double,
        expenseTotal: Double,
        balance: Double
    ) -> some View {
        ReportEstimateView(
            incomeTotal: incomeTotal,
            expenseTotal: expenseTotal,
            balance: balance
        )
    }

    func createChart(
        incomeTotal: Double,
        expenseTotal: Double
    ) -> some View {
        ReportChartView(
            incomeTotal: incomeTotal,
            expenseTotal: expenseTotal
        )
    }
}
