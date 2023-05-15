//
//  ExportPDFView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/5/23.
//

import SwiftUI
import PDFKit
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
        ShareLink("share.pdf", item: render())
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
        var pdfs = [PDFDocument]()

        subrenderSources(pdfs: &pdfs)

        let estimateURL = subrender(
            fileName: "estimate.pdf",
            content: createEstimate(
                incomeTotal: incomeTotal ?? 0.0,
                expenseTotal: expenseTotal ?? 0.0,
                balance: balance ?? 0.0,
                recurrence: recurrence
            )
        )
        let estimatePDF = PDFDocument(url: estimateURL)!
        pdfs.append(estimatePDF)

        let firstPDF = pdfs.first!
        for pdf in pdfs {
            guard pdf != firstPDF else {
                continue
            }
            firstPDF.addPages(from: pdf)
        }

        let url = URL.documentsDirectory.appending(path: "report.pdf")

        let data = firstPDF.dataRepresentation()!
        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }

        let reportPDF = PDFDocument(url: url)
        return reportPDF?.documentURL ?? estimateURL
    }

    func subrender(fileName: String, content: some View) -> URL {
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

    private func subrenderSources(pdfs: inout [PDFDocument]) {
        let incomes = mainData.financeData.incomes
        let expenses = mainData.financeData.expenses
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
            let sourcesPDF = PDFDocument(url: sourcesURL)!
            pdfs.append(sourcesPDF)
            page += 1
        }
    }

    private func processSourcesSection(
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
