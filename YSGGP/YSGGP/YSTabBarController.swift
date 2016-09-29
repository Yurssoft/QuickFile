//
//  YSTabBarController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSTabBarController: UITabBarController
{
    var driveCoordinator : YSDriveCoordinator?
    override func viewDidLoad()
    {
        var driveVC : YSDriveViewController?
        
        if let tabViewControllers = viewControllers
        {
            for navigationViewController in tabViewControllers
            {
                for viewController in navigationViewController.childViewControllers
                {
                    if viewController is YSDriveViewController
                    {
                        driveVC = (viewController as? YSDriveViewController)!
                    }
                }
            }
        }
        if driveVC == nil
        {
            print("driveVC == nil")
        }
        if driveVC?.navigationController == nil
        {
            print("navigationController == nil")
        }
        driveCoordinator = YSDriveCoordinator(driveViewController: driveVC!, navigationController: (driveVC?.navigationController!)!)
        driveCoordinator?.start()
    }
}
