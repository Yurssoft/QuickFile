//
//  YSTabBarController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/21/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var driveTopViewController : YSDriveTopViewController? = nil
        for navigationVC in childViewControllers
        {
            for topVC in navigationVC.childViewControllers
            {
                if let drTopVC = topVC as? YSDriveTopViewController
                {
                    driveTopViewController = drTopVC
                }
            }
        }
        let coordinator = YSDriveCoordinator()
        driveTopViewController?.driveVCReadyDelegate = coordinator
    }
}
