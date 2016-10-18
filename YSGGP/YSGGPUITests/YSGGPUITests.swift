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
    }
    
    func testLoginToDrive()
    {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        app.tables.staticTexts["Log In To Drive"].tap()
        
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
        enterThe8DigitCodeTextField.typeText("48416371")
        app.otherElements["Google Accounts"].buttons["Done"].tap()
        
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
