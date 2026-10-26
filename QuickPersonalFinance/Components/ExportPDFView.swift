//
//  ExportPDFView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/5/23.
//

import SwiftUI
import PDFKit
import Charts
import UIKit

/// Reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-a-swiftui-view-to-a-pdf
@MainActor
struct ExportPDFView: View {
    @EnvironmentObject private var mainData: AppData
    var recurrence: Recurrence
    private let settings: SettingsService
    @Binding var isExporting: Bool
    @Binding var exportShare: ExportShare?
    @Binding var errorMessage: String?
    @Binding var isErrorPresented: Bool

    var body: some View {
        Button {
            let request = ExportRequest(
                financeData: mainData.financeData,
                recurrence: recurrence,
                settings: settings,
                isExporting: $isExporting,
                exportShare: $exportShare,
                errorMessage: $errorMessage,
                isErrorPresented: $isErrorPresented
            )
            Task {
                await Self.performExport(request)
            }
        } label: {
            Text("share.pdf")
        }
        .disabled(isExporting)
    }

    /// First export pays for text and share-sheet setup. Do that before the user asks, when possible.
    static func prewarmExportIfNeeded() {
        guard !didPrewarmExport else {
            return
        }
        didPrewarmExport = true

        let activity = UIActivityViewController(
            activityItems: [URL(fileURLWithPath: NSTemporaryDirectory())],
            applicationActivities: nil
        )
        activity.loadViewIfNeeded()

        let renderer = ImageRenderer(
            content: Text(verbatim: " ")
                .font(Font.Report.standard)
        )
        renderer.scale = 1
        _ = renderer.uiImage
    }

    static func render(
        financeData: FinanceData,
        recurrence: Recurrence,
        settings: SettingsService
    ) async throws -> URL {
        // Render sources of incomes and expenses pages
        var pageURLs = await subrenderSources(financeData: financeData, currencyID: settings.currencyID)
        await waitForDrawnFrame()

        // Render the estimage page
        let summary = EstimateSummary(
            financeData: financeData,
            recurrence: recurrence,
            currencyID: settings.currencyID,
            calculation: Calculation(settings: settings)
        )
        pageURLs.append(
            subrender(
                fileName: "estimate.pdf",
                content: ReportEstimateView(summary: summary)
            )
        )

        let reportsUrl = URL.documentsDirectory.appending(path: "reports")
        let reportURL = reportsUrl.appending(path: "\("share.report.report".localized).pdf")
        let wrote = await Task.detached(priority: .userInitiated) {
            writeReport(from: pageURLs, to: reportURL)
        }.value
        guard wrote else {
            throw ExportError.renderFailed
        }
        return reportURL
    }

    /// PDFKit merge and the file write stay off the main thread so the wait indicator can keep moving.
    private nonisolated static func writeReport(from pageURLs: [URL], to reportURL: URL) -> Bool {
        guard let firstURL = pageURLs.first, let report = PDFDocument(url: firstURL) else {
            return false
        }
        for url in pageURLs.dropFirst() {
            guard let document = PDFDocument(url: url) else {
                return false
            }
            report.addPages(from: document)
        }
        do {
            try FileManager.default.createDirectory(
                at: reportURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            guard let data = report.dataRepresentation() else {
                return false
            }
            try data.write(to: reportURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    static func subrender(fileName: String, content: some View) -> URL {
        let url = URL.temporaryDirectory.appending(path: fileName)
        let renderer = ImageRenderer(
            content: content
        )
        // Screen scale (2x/3x) rasterizes a full letter page on first use and freezes the UI.
        renderer.scale = 1

        renderer.render { _, renderer in
            var box = CGRect(origin: .zero, size: PageMetrics.pageSize)

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

    private static func subrenderSources(
        financeData: FinanceData,
        currencyID: String
    ) async -> [URL] {
        var pageURLs = [URL]()
        let incomes = financeData.incomes
        let expenses = financeData.expenses
        let limit = PageMetrics.sourcesPerPage
        var page = 1, incomesIndex = 0, expensesIndex = 0
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
            pageURLs.append(
                subrender(
                    fileName: "sources-\(page).pdf",
                    content: ReportSourcesView(
                        mainTitle: mainTitle,
                        sectionTitles: sectionTitles,
                        sources: sources,
                        currencyID: currencyID
                    )
                )
            )
            page += 1
            await waitForDrawnFrame()
        }
        return pageURLs
    }

    /// `Task.yield()` can resume before SwiftUI draws. Two main-queue turns let the overlay commit.
    private static func waitForDrawnFrame() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    continuation.resume()
                }
            }
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

    init(
        recurrence: Recurrence,
        settings: SettingsService,
        isExporting: Binding<Bool>,
        exportShare: Binding<ExportShare?>,
        errorMessage: Binding<String?>,
        isErrorPresented: Binding<Bool>
    ) {
        self.recurrence = recurrence
        self.settings = settings
        _isExporting = isExporting
        _exportShare = exportShare
        _errorMessage = errorMessage
        _isErrorPresented = isErrorPresented
    }

    /// Shows the wait indicator, then renders. The share sheet hides the indicator once it is ready.
    private static func performExport(_ request: ExportRequest) async {
        guard !request.isExporting.wrappedValue else {
            return
        }
        request.isExporting.wrappedValue = true
        await waitForDrawnFrame()
        prewarmExportIfNeeded()
        await waitForDrawnFrame()
        do {
            let url = try await render(
                financeData: request.financeData,
                recurrence: request.recurrence,
                settings: request.settings
            )
            request.exportShare.wrappedValue = ExportShare(url: url)
        } catch {
            request.isExporting.wrappedValue = false
            request.errorMessage.wrappedValue = (error as? LocalizedError)?.errorDescription
                ?? StandardError.unknown.localizedDescription
            request.isErrorPresented.wrappedValue = true
        }
    }

    private static var didPrewarmExport = false
}

private struct ExportRequest {
    let financeData: FinanceData
    let recurrence: Recurrence
    let settings: SettingsService
    let isExporting: Binding<Bool>
    let exportShare: Binding<ExportShare?>
    let errorMessage: Binding<String?>
    let isErrorPresented: Binding<Bool>
}

// MARK: - Share

struct ExportShare: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    @Binding var share: ExportShare?
    var onPresented: () -> Void

    func makeUIViewController(context: Context) -> ShareHostViewController {
        let host = ShareHostViewController()
        host.view.backgroundColor = .clear
        return host
    }

    func updateUIViewController(_ host: ShareHostViewController, context: Context) {
        host.onPresented = onPresented
        host.onDismissed = {
            DispatchQueue.main.async {
                share = nil
            }
        }
        let share = share
        DispatchQueue.main.async {
            host.present(share: share)
        }
    }
}

final class ShareHostViewController: UIViewController {
    var onPresented: () -> Void = {}
    var onDismissed: () -> Void = {}
    private var activeShareID: UUID?
    private var pendingShare: ExportShare?

    func present(share: ExportShare?) {
        guard let share, activeShareID != share.id, presentedViewController == nil else {
            return
        }
        guard let source = view.window else {
            pendingShare = share
            return
        }
        pendingShare = nil
        activeShareID = share.id

        let controller = UIActivityViewController(
            activityItems: [share.url],
            applicationActivities: nil
        )
        if let popover = controller.popoverPresentationController {
            popover.sourceView = source
            let bounds = source.bounds
            popover.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        controller.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.activeShareID = nil
            self?.onDismissed()
        }
        onPresented()
        present(controller, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let pendingShare else {
            return
        }
        present(share: pendingShare)
    }
}

extension ExportPDFView {
    enum ExportError: LocalizedError {
        case renderFailed

        var errorDescription: String? {
            StandardError.unknown.localizedDescription
        }
    }
}
