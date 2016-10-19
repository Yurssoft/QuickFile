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
        app.navigationBars["GTMOAuth2View"].buttons["Cancel"].tap()
        
        let tabBarsQuery = app.tabBars
        let playlistButton = tabBarsQuery.buttons["Playlist"]
        playlistButton.tap()
        tabBarsQuery.buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.children(matching: .other).element(boundBy: 0).otherElements["Info"].tap()
        tablesQuery.children(matching: .other).element(boundBy: 1).otherElements["Actions"].tap()
        playlistButton.tap()
        tabBarsQuery.buttons["Drive"].tap()
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
        
        sleep(5)
        if app.staticTexts["Wrong code. Try again."].exists || app.staticTexts["Wrong number of digits. Please try again."].exists
        {
            XCTFail("Wrong code or Wrong number of digits")
            return
        }
        
        let allowButton = app.otherElements["Request for Permission"].buttons["Allow"]
        let isHittablePredicate = NSPredicate(format: "isHittable == true")
        expectation(for: isHittablePredicate, evaluatedWith: allowButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        app.otherElements["Request for Permission"].buttons["Allow"].tap()
        
        let object = app.tables.staticTexts["Log Out From Drive"]
        let logOutExistsPredicate = NSPredicate(format: "exists == true", "Wrong label text")
        expectation(for: logOutExistsPredicate, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogOut ()
    {
        
    }
}
