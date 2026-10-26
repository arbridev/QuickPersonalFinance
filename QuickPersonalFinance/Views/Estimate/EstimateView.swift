//
//  EstimateView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI
import Charts

struct EstimateView: View {

    // MARK: Properties

    @EnvironmentObject private var mainData: AppData
    @StateObject private var viewModel: ViewModel

    private let services: AppServices
    let barChartColors: [Color] = [.Palette.incomeTable, .Palette.expenseTable]

    var body: some View {
        VStack {
            // MARK: Top bar
            HStack {
                Spacer()
                Button {
                    viewModel.isPresentingSettings = true
                    HapticsService().impactFeedback(style: .light)
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .accessibilityLabel("accessibility.settings")
                .padding(.trailing)
                .sheet(isPresented: $viewModel.isPresentingSettings) {
                    SettingsActionView(settings: services.settings)
                }
            }

            Text("estimate.title")
                .asScreenTitle()

            Spacer()

            VStack {
                // MARK: Time span selection
                HStack {
                    Text("\("estimate.action.time.span".localized):")
                    Picker(
                        "action.field.recurrence".localized,
                        selection: $viewModel.selectedRecurrence
                    ) {
                        ForEach(Recurrence.allCases, id: \.rawValue) { recurrence in
                            Text(recurrence.rawValue.localized.capitalized)
                                .font(.App.input)
                                .tag(recurrence)
                        }
                    }
                    .tint(Color.Palette.estimateAccentSecondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                .font(.App.input)

                Divider()
                    .overlay(Color.Palette.dividerPrimary)
                    .padding(.horizontal)

                // MARK: Estimate table
                EstimateTableView(summary: viewModel.summary)

                // MARK: Share
                Menu {
                    ShareLink(item: viewModel.summary.shareMessage) {
                        Label("share.summary", systemImage: "square.and.arrow.up")
                    }
                    ExportPDFView(
                        recurrence: viewModel.selectedRecurrence,
                        settings: services.settings,
                        isExporting: $viewModel.isExportingPDF,
                        exportShare: $viewModel.exportShare,
                        errorMessage: $viewModel.exportErrorMessage,
                        isErrorPresented: $viewModel.isExportErrorPresented
                    )
                    .environmentObject(mainData)
                } label: {
                    Label("estimate.button.share", systemImage: "square.and.arrow.up")
                }
                .onTapGesture {
                    HapticsService().impactFeedback(style: .light)
                    DispatchQueue.main.async {
                        ExportPDFView.prewarmExportIfNeeded()
                    }
                }

                Divider()
                    .overlay(Color.Palette.dividerSecondary)
                    .padding(.vertical)

                // MARK: Chart
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                        Chart {
                            ForEach(viewModel.barChartData, id: \.title) { barValue in
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
                        .frame(width: min(geometry.size.width, geometry.size.height) / 1.20, alignment: .center)
                        Spacer()
                    }
                }
            }
            .padding()
            .onAppear {
                viewModel.input(mainData: mainData)
                viewModel.update()
            }
            .onChange(of: mainData.financeData) { _ in
                viewModel.update()
            }

            Button {
                viewModel.isPresentingCurrencyConversion = true
                HapticsService().impactFeedback()
            } label: {
                Text("estimate.convert.currency")
                    .font(.App.input)
            }
            .sheet(isPresented: $viewModel.isPresentingCurrencyConversion) {
                ConvertedEstimateView(services: services, recurrence: viewModel.selectedRecurrence)
                    .environmentObject(mainData)
            }

            Spacer()
        }
        .overlay {
            if viewModel.isExportingPDF {
                exportProgressHUD
            }
        }
        .background {
            ActivityShareSheet(share: $viewModel.exportShare) {
                viewModel.isExportingPDF = false
            }
        }
        .alert(viewModel.exportErrorMessage ?? "", isPresented: $viewModel.isExportErrorPresented) {
            Button("action.button.ok", role: .cancel) {}
        }
    }

    private var exportProgressHUD: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                Text("share.pdf.preparing")
                    .font(Font.App.standard)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("share.pdf.preparing"))
    }

    // MARK: Initialization

    init(services: AppServices) {
        self.services = services
        _viewModel = StateObject(wrappedValue: ViewModel(settings: services.settings))
    }
}

// MARK: - Previews

struct EstimateView_Previews: PreviewProvider {
    static var envObject: AppData {
        let data = AppData()
        let incomes = [
            MockData.income1
        ]

        let expenses = [
            MockData.expense1
        ]

        data.financeData = FinanceData(
            incomes: incomes,
            expenses: expenses
        )
        return data
    }
    
    static var previews: some View {
        EstimateView(services: .preview)
            .environmentObject(envObject)
//            .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
    }
}
