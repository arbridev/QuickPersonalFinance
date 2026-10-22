//
//  ExportPDFView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/5/23.
//

import SwiftUI
import PDFKit
import Charts
import UniformTypeIdentifiers

/// Reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-a-swiftui-view-to-a-pdf
@MainActor
struct ExportPDFView: View {
    @EnvironmentObject private var mainData: AppData
    var recurrence: Recurrence

    var body: some View {
        ShareLink(
            "share.pdf",
            item: Report(financeData: mainData.financeData, recurrence: recurrence),
            preview: SharePreview(Text("share.report.report"))
        )
    }

    static func render(financeData: FinanceData, recurrence: Recurrence) throws -> URL {
        var pdfs = [PDFDocument]()

        // Render sources of incomes and expenses pages
        try subrenderSources(financeData: financeData, pdfs: &pdfs)

        // Render the estimage page
        let calculations = Calculation()
        let estimateURL = subrender(
            fileName: "estimate.pdf",
            content: createEstimate(
                incomeTotal: calculations.totalize(sources: financeData.incomes, to: recurrence),
                expenseTotal: calculations.totalize(sources: financeData.expenses, to: recurrence),
                balance: calculations.makeBalance(
                    incomes: financeData.incomes,
                    expenses: financeData.expenses,
                    basedOn: recurrence
                ),
                recurrence: recurrence
            )
        )
        pdfs.append(try document(at: estimateURL))

        let report = pdfs[0]
        for pdf in pdfs.dropFirst() {
            report.addPages(from: pdf)
        }

        // Create reports directory inside the Documents directory
        let reportsUrl = URL.documentsDirectory.appending(path: "reports")
        try FileManager.default.createDirectory(at: reportsUrl, withIntermediateDirectories: true)

        // Create the Report PDF
        let reportURL = reportsUrl.appending(path: "\("share.report.report".localized).pdf")
        guard let data = report.dataRepresentation() else {
            throw ExportError.renderFailed
        }
        try data.write(to: reportURL)
        return reportURL
    }

    private static func document(at url: URL) throws -> PDFDocument {
        guard let document = PDFDocument(url: url) else {
            throw ExportError.renderFailed
        }
        return document
    }

    static func subrender(fileName: String, content: some View) -> URL {
        let url = URL.temporaryDirectory.appending(path: fileName)
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

    private static func subrenderSources(financeData: FinanceData, pdfs: inout [PDFDocument]) throws {
        let incomes = financeData.incomes
        let expenses = financeData.expenses
        let limit = 25
        var page = 1
        var incomesIndex = 0
        var expensesIndex = 0
        var sources = [[any Source]?]()

        while incomesIndex < incomes.count || expensesIndex < expenses.count {
            var pageIncomes: [any Source]?
            var pageExpenses: [any Source]?
            let mainTitle = page == 1 ? "share.report.report" : nil
            var sectionTitles = [String?]()
            if incomesIndex < incomes.count {
                sectionTitles.append(incomesIndex == 0 ? "incomes.title" : nil)
                processSourcesSection(
                    sources: incomes,
                    sourcesIndex: &incomesIndex,
                    pageSources: &pageIncomes,
                    limit: limit
                )
            } else {
                sectionTitles.append(nil)
            }
            if expensesIndex < expenses.count && pageIncomes == nil {
                sectionTitles.append(expensesIndex == 0 ? "expenses.title" : nil)
                processSourcesSection(
                    sources: expenses,
                    sourcesIndex: &expensesIndex,
                    pageSources: &pageExpenses,
                    limit: limit
                )
            } else {
                sectionTitles.append(nil)
            }
            sources = [pageIncomes, pageExpenses]
            let sourcesURL = subrender(
                fileName: "sources-\(page).pdf",
                content: createSources(
                    mainTitle: mainTitle,
                    sectionTitles: sectionTitles,
                    sources: sources
                )
            )
            pdfs.append(try document(at: sourcesURL))
            page += 1
        }
    }

    private static func processSourcesSection(
        sources: [any Source],
        sourcesIndex: inout Int,
        pageSources: inout [any Source]?,
        limit: Int
    ) {
        let itemsLeft = sources.suffix(from: sourcesIndex)
        if itemsLeft.count > limit {
            let lastIndex = sourcesIndex + limit
            pageSources = Array(itemsLeft.prefix(upTo: lastIndex))
            sourcesIndex = lastIndex
        } else {
            pageSources = Array(itemsLeft)
            sourcesIndex = sources.count
        }
    }

    init(recurrence: Recurrence) {
        self.recurrence = recurrence
    }
}

// MARK: - Report

extension ExportPDFView {
    enum ExportError: Error {
        case renderFailed
    }


    /// Renders the PDF only when the share sheet requests the file
    struct Report: Transferable {
        let financeData: FinanceData
        let recurrence: Recurrence

        static var transferRepresentation: some TransferRepresentation {
            FileRepresentation(exportedContentType: .pdf) { report in
                let url = try await ExportPDFView.render(
                    financeData: report.financeData,
                    recurrence: report.recurrence
                )
                return SentTransferredFile(url)
            }
        }
    }
}
