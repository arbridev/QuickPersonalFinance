//
//  ExportPDFView+Report.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 13/5/23.
//

import SwiftUI
import Charts

extension ExportPDFView {
    // MARK: - PageMetrics
    /// US Letter page geometry, in PDF points.
    enum PageMetrics {
        static let dpi: Double = 72
        static let pageSize = CGSize(width: 8.5 * dpi, height: 11 * dpi)
        static let horizontalMargins: Double = 0.75 * 2 * dpi
        static let verticalMargins: Double = 0.75 * 2 * dpi
        static let contentWidth = pageSize.width - horizontalMargins
        static let contentHeight = pageSize.height - verticalMargins
        /// Source rows that fit on a page below the titles.
        static let sourcesPerPage = 25
    }

    // MARK: - ReportSourcesView
    struct ReportSourcesView: View {
        var mainTitle: String?
        var sectionTitles: [String?]
        var sources: [[any Source]?]
        var currencyID: String

        var body: some View {
            HStack {
                Spacer(minLength: PageMetrics.horizontalMargins / 2)
                VStack {
                    // MARK: Main title
                    if let mainTitle {
                        // LocalizedStringKey does not work on PDF rendering
                        Text(mainTitle.localized)
                            .font(Font.Report.mainTitle)
                            .foregroundColor(.black)
                            .padding()

                        Divider()
                    }

                    // MARK: Sections
                    ForEach(0..<sectionTitles.count, id: \.self) { index in
                        if let sectionTitle = sectionTitles[index] {
                            HStack {
                                Text(sectionTitle.localized)
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
                                            Text(recurrence.rawValue.localized)
                                                .font(Font.Report.info)
                                        }
                                        Spacer()
                                        Text(source.grossValue.asCurrency(withID: currencyID))
                                            .font(Font.Report.standard)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    ReportPageFooter()
                }
                .frame(
                    width: PageMetrics.contentWidth,
                    height: PageMetrics.contentHeight,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - ReportEstimateView
    struct ReportEstimateView: View {
        let summary: EstimateSummary

        var body: some View {
            HStack {
                Spacer(minLength: PageMetrics.horizontalMargins / 2)
                VStack {
                    // MARK: Title
                    HStack {
                        Text("estimate.title".localized)
                            .font(Font.Report.title1)
                            .padding(.bottom, 10)
                        Spacer()
                    }

                    Divider()

                    Group {
                        VStack {
                            HStack {
                                Text("estimate.table.income".localized)
                                Spacer()
                                Text(summary.incomeTotal.asCurrency(withID: summary.currencyID))
                            }
                        }

                        VStack {
                            HStack {
                                Text("estimate.table.expense".localized)
                                Spacer()
                                Text(summary.expenseTotal.asCurrency(withID: summary.currencyID))
                            }
                        }

                        Divider()

                        VStack {
                            HStack {
                                Text("estimate.table.total".localized)
                                Spacer()
                                Text(summary.balance.asCurrency(withID: summary.currencyID))
                            }
                        }

                        Text(summary.shareMessage)
                            .font(Font.Report.info)
                            .padding(.top, 8)
                    }

                    Divider()
                        .padding(.vertical)

                    ReportChartView(incomeTotal: summary.incomeTotal, expenseTotal: summary.expenseTotal)

                    Spacer()

                    ReportPageFooter()
                }
                .frame(
                    width: PageMetrics.contentWidth,
                    height: PageMetrics.contentHeight,
                    alignment: .center
                )
                .font(Font.Report.standard)
            }
        }
    }

    // MARK: - ReportChartView
    struct ReportChartView: View {
        struct BarValue {
            let title: String
            let total: Double
        }

        let barChartColors: [Color] = [.Palette.incomeTable, .Palette.expenseTable]

        var incomeTotal: Double
        var expenseTotal: Double

        private var barChartData: [BarValue] {
            [
                BarValue(title: "estimate.table.income".localized, total: incomeTotal),
                BarValue(title: "estimate.table.expense".localized, total: expenseTotal)
            ]
        }

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
                    .frame(
                        width: PageMetrics.contentWidth / 2,
                        height: PageMetrics.contentHeight / 2,
                        alignment: .center
                    )

                    Spacer()
                }
                .frame(
                    width: PageMetrics.contentWidth / 2,
                    height: PageMetrics.contentHeight / 2,
                    alignment: .center
                )
            }
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
}
