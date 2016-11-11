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
//    override func setUp()
//    {
//        super.setUp()
//        continueAfterFailure = true
//        XCUIApplication().launch()
//        XCUIDevice.shared().orientation = .faceUp
//    }
//    
//    func testLoginToDrive()
//    {
//        let app = XCUIApplication()
//        app.tabBars.buttons["Settings"].tap()
//        
//        app.tables.staticTexts["Log In To Drive"].tap()
//        
//        let enterYourEmailTextField = app.textFields["Enter your email"]
//        enterYourEmailTextField.tap()
//        enterYourEmailTextField.typeText("yurii.boiko.s@gmail.com")
//        app.otherElements["Sign in - Google Accounts"].buttons["Next"].tap()
//        
//        let passwordSecureTextField = app.secureTextFields["Password"]
//        passwordSecureTextField.tap()
//        passwordSecureTextField.typeText("PsN-uQv-yKC-7Ck")
//        
//        app.buttons["Sign in"].tap()
//        
//        let allowButton = app.otherElements["Request for Permission"].buttons["Allow"]
//        let isHittablePredicate = NSPredicate(format: "isHittable == true")
//        expectation(for: isHittablePredicate, evaluatedWith: allowButton, handler: nil)
//        waitForExpectations(timeout: 150, handler: nil)
//        app.otherElements["Request for Permission"].buttons["Allow"].tap()
//        
//        let object = app.tables.staticTexts["Log Out From Drive"]
//        let logOutExistsPredicate = NSPredicate(format: "exists == true", "Wrong label text")
//        expectation(for: logOutExistsPredicate, evaluatedWith: object, handler: nil)
//        waitForExpectations(timeout: 150, handler: nil)
//    }
//}
