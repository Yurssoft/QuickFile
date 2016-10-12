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
        let navigationBar = app.navigationBars["YSGGP.YSDriveTopView"]
        navigationBar.buttons["Login"].tap()
        app.buttons["Next"].tap()
        app.textFields["Enter your email"].tap()
        app.navigationBars["GTMOAuth2View"].buttons["Cancel"].tap()
        navigationBar.buttons["Edit"].tap()
        
        app.navigationBars["YSGGP.YSDriveTopView"].buttons["Done"].tap()
        
        let tabBars = app.tabBars
        tabBars.buttons["Playlist"].tap()
        tabBars.buttons["Settings"].tap()
        app.tables.staticTexts["You are Logged in to Drive"].tap()
    }
    
    func testLoginToDrive()
    {
        let app = XCUIApplication()
        app.navigationBars["YSGGP.YSDriveTopView"].buttons["Login"].tap()
        let enterYourEmailTextField = app.textFields["Enter your email"]
        enterYourEmailTextField.tap()
        enterYourEmailTextField.typeText("yurssoft@gmail.com")
        app.otherElements["Sign in - Google Accounts"].buttons["Next"].tap()
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Yurs-soft06712997188")
        
        app.buttons["Sign in"].tap()
        app.buttons["Try another way to sign in"].tap()
        app.buttons["Use one of your 8-digit backup codes"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        
        let enterThe8DigitCodeTextField = app.textFields["Enter the 8-digit code"]
        enterThe8DigitCodeTextField.tap()
        enterThe8DigitCodeTextField.typeText("22242774")
        app.otherElements["Google Accounts"].buttons["Done"].tap()
        
        XCTAssertFalse(app.staticTexts["Wrong code. Try again."].exists, "Wrong backup code")
        
        let allowButton = app.otherElements["Request for Permission"].buttons["Allow"]
        let isHittablePredicate = NSPredicate(format: "isHittable == true")
        expectation(for: isHittablePredicate, evaluatedWith: allowButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        app.otherElements["Request for Permission"].buttons["Allow"].tap()
        
        let loginButton = app.navigationBars["YSGGP.YSDriveTopView"].buttons["Login"]
        let loginExistsPredicate = NSPredicate(format: "exists == false")
        expectation(for: loginExistsPredicate, evaluatedWith: loginButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogOut ()
    {
        
    }
}
