//
//  YSGGPTests.swift
//  YSGGPTests
//
//  Created by Yurii Boiko on 9/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import XCTest
import GTMOAuth2
@testable import YSGGP

class YSGGPDriveCoordinatorTests: XCTestCase
{
    let coordinator = YSDriveCoordinator.init(driveViewController: YSDriveViewController(), navigationController: UINavigationController())

    func testInitialDefaults()
    {
        XCTAssertNotNil(coordinator.navigationController)
        XCTAssertNotNil(coordinator.driveViewController)
    }
    
    func testStart()
    {
        coordinator.start()
        XCTAssertNotNil(coordinator.driveViewController?.viewModel)
        XCTAssertNotNil(coordinator.driveViewController?.viewModel?.model)
        XCTAssertNotNil(coordinator.driveViewController?.viewModel?.coordinatorDelegate)
    }
}
