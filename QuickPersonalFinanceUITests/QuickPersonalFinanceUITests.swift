//
//  QuickPersonalFinanceUITests.swift
//  QuickPersonalFinanceUITests
//
//  Created by Armando Brito on 9/3/23.
//

import XCTest

final class QuickPersonalFinanceUITests: XCTestCase {

    func testMainFlow() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-testing"]

        // Comment the next line if you follow the alternate flow without setupSnapshot
        setupSnapshot(app)
        // Alternate flow without setupSnapshot
//        app.launchArguments += ["-AppleLanguages", "(en-US)"]
//        app.launchArguments += ["-AppleLocale", "en_US"]
//        app.launchArguments += ["-AppleLanguages", "(es_419)"]
//        app.launchArguments += ["-AppleLocale", "es_419"]
//        deviceLanguage = "en-US"
//        deviceLanguage = "es-419"

        app.launch()

        print("Launch arguments:", app.launchArguments)
        print(Bundle(for: QuickPersonalFinanceUITests.self).bundlePath)
        print("Documents directory:", URL.documentsDirectory)

        // Incomes

        fillIncomes(app)

        snapshot("incomes")

        // Expenses

        app.tabBars["test.tab.bar".localized]
            .buttons["expenses.title".localized]
            .tap()

        fillExpenses(app)

        snapshot("expenses")

        // Estimate

        app.tabBars["test.tab.bar".localized]
            .buttons["estimate.title".localized]
            .tap()

        snapshot("estimate")

        // Currency conversion

        app.buttons["estimate.convert.currency".localized].tap()
        app.staticTexts["USD"].tap()
        app.buttons["EUR"].tap()

        sleep(3)

        snapshot("currency_conversion")

        app.buttons["modal_close"].tap()

        // Share

        app.buttons["estimate.button.share".localized].tap()
        app.buttons["share.pdf".localized].tap()

        let options = app.collectionViews.children(matching: .button)
        options.element(boundBy: options.count - 1).tap()

        sleep(3)

        app.navigationBars["FullDocumentManagerViewControllerNavigationBar"].buttons["test.dialog.save".localized].tap()

        if app.alerts["test.dialog.replace.existing".localized].exists {
            app.alerts["test.dialog.replace.existing".localized]
                .scrollViews
                .otherElements
                .buttons["test.dialog.replace".localized]
                .tap()
        }

        sleep(5)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    private func fillIncomes(_ app: XCUIApplication) {
        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.salary".localized,
            grossValue: "2000",
            recurrence: "month".localized.capitalized,
            screenshotLabel: "create-income"
        )

        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.garage.sale".localized,
            grossValue: "200",
            recurrence: "year".localized.capitalized
        )
    }

    private func fillExpenses(_ app: XCUIApplication) {
        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.utilities".localized,
            grossValue: "200",
            recurrence: "month".localized.capitalized,
            screenshotLabel: "create-expense"
        )

        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.food".localized,
            grossValue: "150",
            recurrence: "month".localized.capitalized
        )

        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.streaming".localized,
            grossValue: "25",
            recurrence: "month".localized.capitalized
        )

        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.taxes".localized,
            grossValue: "7200",
            recurrence: "year".localized.capitalized
        )

        app.buttons["test.add".localized].tap()
        fillSourceCreation(
            app,
            name: "test.leisure".localized,
            grossValue: "30",
            recurrence: "month".localized.capitalized
        )
    }

    private func fillSourceCreation(
        _ app: XCUIApplication,
        name: String,
        grossValue: String,
        recurrence: String,
        screenshotLabel: String? = nil
    ) {
        let collectionViewsQuery = app.collectionViews
        let textFieldName = collectionViewsQuery.textFields["action.field.name".localized]
        textFieldName.tap()
        textFieldName.typeText(name)
        let grossValueTextField = collectionViewsQuery.textFields["action.field.gross.value".localized]
        grossValueTextField.tap()
        grossValueTextField.typeText(grossValue)
        collectionViewsQuery.staticTexts["hour".localized.capitalized].tap()
        app.buttons[recurrence].tap()
        if let screenshotLabel {
            snapshot(screenshotLabel)
        }
        app.buttons["action.button.submit".localized.uppercased()].tap()
    }
}

// swiftlint:disable nslocalizedstring_key
fileprivate extension String {
    var localized: String {
        let testBundle = Bundle(for: QuickPersonalFinanceUITests.self)

        if deviceLanguage.isEmpty {
            return NSLocalizedString(self, bundle: testBundle, comment: "")
        }
        var path: String?
        // In order to work, deviceLanguage value is required to replace the floor "_",
        // with a dash "-"
        path = testBundle.path(forResource: deviceLanguage, ofType: "lproj")
        if path == nil {
            path = testBundle.path(forResource: String(deviceLanguage.prefix(2)), ofType: "lproj")
        }
        guard let path else {
            fatalError("Could not find the .lproj resource, check the test bundle")
        }
        let bundle = Bundle(path: path)!
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
// swiftlint:enable nslocalizedstring_key
