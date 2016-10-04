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
//    var driveCoordinator : YSDriveCoordinator?
//    override func viewDidLoad()
//    {
//        var driveVC : YSDriveViewController?
//        
//        if let tabViewControllers = viewControllers
//        {
//            for navigationViewController in tabViewControllers
//            {
//                for viewController in navigationViewController.childViewControllers
//                {
//                    if viewController is YSDriveViewController
//                    {
//                        driveVC = (viewController as? YSDriveViewController)!
//                    }
//                }
//            }
//        }
//        if driveVC == nil
//        {
//            print("driveVC == nil")
//        }
//        if driveVC?.navigationController == nil
//        {
//            print("navigationController == nil")
//        }
//        driveCoordinator = YSDriveCoordinator(driveViewController: driveVC!, navigationController: (driveVC?.navigationController!)!)
//        driveCoordinator?.start()
//    }
}

extension UITabBarController
{
    func hideTabBar(animated: Bool)
    {
        let screenRect = UIScreen.main.bounds
        var screenHeight = screenRect.size.height
        
        //        if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        if (UIDeviceOrientationIsLandscape(UIDeviceOrientation.init(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!))
        {
            screenHeight = screenRect.size.width
        }
        
        let closure =
        {
            for view in self.view.subviews
            {
                if view == self.tabBar
                {
                    var tabBarFrame = screenRect
                    tabBarFrame.origin.y = screenHeight
                    view.frame = tabBarFrame
                }
                else
                {
                    var viewFrame = screenRect
                    viewFrame.size.height = screenHeight
                    view.frame = viewFrame
                    view.backgroundColor = UIColor.clear
                }
            }
        }
        if animated
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            closure()
            UIView.commitAnimations()
        }
        else
        {
            closure()
        }
    }
}
