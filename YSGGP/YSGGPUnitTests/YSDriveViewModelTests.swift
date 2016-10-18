//
//  YSDriveViewModelTests.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/12/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import XCTest
@testable import YSGGP

class YSDriveViewModelTests: XCTestCase
{
    let viewModel = YSDriveViewModel()
    var currentExpectaion: XCTestExpectation?
    
    func testInitialDefaults()
    {
        XCTAssertNil(viewModel.viewDelegate)
        XCTAssertNil(viewModel.model)
        XCTAssertNil(viewModel.coordinatorDelegate)
        XCTAssertTrue(viewModel.numberOfItems == 0)
    }
    
    func testItemsDidChange()
    {
        viewModel.viewDelegate = self
        viewModel.model = YSDriveModel()
        let itemsPredicate = NSPredicate(format: "self > 0")
        currentExpectaion = expectation(for: itemsPredicate, evaluatedWith: viewModel.numberOfItems, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension YSDriveViewModelTests : YSDriveViewModelViewDelegate
{
    func itemsDidChange(viewModel: YSDriveViewModel)
    {
        if !viewModel.isItemsPresent
        {
            return
        }
        XCTAssertTrue(viewModel.numberOfItems > 0)
        XCTAssertNotNil(viewModel.itemAtIndex(0))
        let item = viewModel.itemAtIndex(0)
        XCTAssertFalse((item?.fileName.isEmpty)!)
        XCTAssertFalse((item?.fileInfo.isEmpty)!)
        currentExpectaion?.fulfill()
    }
    func errorDidChange(viewModel: YSDriveViewModel, error: YSError)
    {
        
    }
}

