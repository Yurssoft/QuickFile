//
//  YSGGPUITests.swift
//  YSGGPUITests
//
//  Created by Yurii Boiko on 9/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import XCTest

class YSGGPUITests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        continueAfterFailure = true
        XCUIApplication().launch()
        XCUIDevice.shared().orientation = .faceUp
    }
    
    func testInitialView()
    {
        
        let app = XCUIApplication()
        app.navigationBars["YSGGP.YSDriveTopView"].buttons["Login"].tap()
        
        let nextButton = app.buttons["Next"]
        nextButton.tap()
        
        let cancelButton = app.navigationBars["GTMOAuth2View"].buttons["Cancel"]
        cancelButton.tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Playlist"].tap()
        tabBarsQuery.buttons["Settings"].tap()
        app.tables.staticTexts["Log In To Drive"].tap()
        cancelButton.tap()
    }
    
    func testLoginToDrive()
    {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        app.tables.staticTexts["Log In To Drive"].tap()
        
        let enterYourEmailTextField = app.textFields["Enter your email"]
        enterYourEmailTextField.tap()
        enterYourEmailTextField.typeText("yurii.boiko.s@gmail.com")
        app.otherElements["Sign in - Google Accounts"].buttons["Next"].tap()
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("PsN-uQv-yKC-7Ck")
        
        app.buttons["Sign in"].tap()
        
        let allowButton = app.otherElements["Request for Permission"].buttons["Allow"]
        let isHittablePredicate = NSPredicate(format: "isHittable == true")
        expectation(for: isHittablePredicate, evaluatedWith: allowButton, handler: nil)
        waitForExpectations(timeout: 150, handler: nil)
        app.otherElements["Request for Permission"].buttons["Allow"].tap()
        
        let object = app.tables.staticTexts["Log Out From Drive"]
        let logOutExistsPredicate = NSPredicate(format: "exists == true", "Wrong label text")
        expectation(for: logOutExistsPredicate, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 150, handler: nil)
    }
    
    func testLogOut ()
    {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        app.tables.staticTexts["Log Out From Drive"].tap()
        app.sheets["Log Out?"].buttons["Log Out"].tap()
    }
}
