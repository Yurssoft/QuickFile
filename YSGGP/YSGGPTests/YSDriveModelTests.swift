//
//  YSDriveModelTests.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/11/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import XCTest
@testable import YSGGP

class YSDriveModelTests: XCTestCase
{
    func testItems()
    {
        let driveModel = YSDriveModel()
        XCTAssertTrue(driveModel.isLoggedIn, "To get items - login")
        driveModel.items { (items) in
            XCTAssertTrue(items.count > 0)
            let item = items.first! as YSDriveItem
            XCTAssertFalse(item.fileName.isEmpty)
            XCTAssertFalse(item.fileInfo.isEmpty)
        }
    }
}
