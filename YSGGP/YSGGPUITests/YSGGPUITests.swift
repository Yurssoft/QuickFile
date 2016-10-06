//
//  YSGGPUITests.swift
//  YSGGPUITests
//
//  Created by Yurii Boiko on 9/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import XCTest

class YSGGPUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
        enterThe8DigitCodeTextField.typeText("32337177")
        app.otherElements["Google Accounts"].buttons["Done"].tap()
        app.buttons["Allow"].tap()
        
        sleep(30)
        app.buttons["Edit"].tap()
        sleep(30)
    }
    
}
