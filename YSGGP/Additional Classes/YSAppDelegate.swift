//
//  AppDelegate.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GTMOAuth2

@UIApplicationMain
class YSAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var driveCoordinator : YSDriveCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
//        GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: YSConstants.kDriveKeychainAuthorizerName)
        return true
    }
}

