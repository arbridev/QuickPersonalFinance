//
//  QuickPersonalFinanceUITests.swift
//  QuickPersonalFinanceUITests
//
//  Created by Armando Brito on 9/3/23.
//

import XCTest

final class QuickPersonalFinanceUITests: XCTestCase {

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["-testing"]
        app.launch()

        app.buttons["Add"].tap()
        fillSourceCreation(app, name: "Salary", grossValue: "2000")

        app.buttons["Add"].tap()
        fillSourceCreation(app, name: "Garage sale", grossValue: "200")

        XCUIApplication().tabBars["Tab Bar"].buttons["Expenses"].tap()

        app.buttons["Add"].tap()
        fillSourceCreation(app, name: "Salary", grossValue: "2000")

        app.buttons["Add"].tap()
        fillSourceCreation(app, name: "Garage sale", grossValue: "200")

        app.buttons["Add"].tap()
        fillSourceCreation(app, name: "Garage sale", grossValue: "200")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    private func fillSourceCreation(
        _ app: XCUIApplication,
        name: String,
        grossValue: String
    ) {
        let collectionViewsQuery = app.collectionViews
        let textFieldName = collectionViewsQuery.textFields["Name"]
        textFieldName.tap()
        textFieldName.typeText(name)
        let grossValueTextField = collectionViewsQuery.textFields["Gross value"]
        grossValueTextField.tap()
        grossValueTextField.typeText(grossValue)
        collectionViewsQuery.staticTexts["Hour"].tap()
        app.buttons["Month"].tap()
        app.buttons["SUBMIT"].tap()
    }
}
