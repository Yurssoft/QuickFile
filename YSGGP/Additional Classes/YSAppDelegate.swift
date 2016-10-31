//
//  AppDelegate.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GTMOAuth2
import GoogleAPIClientForREST
import Firebase

@UIApplicationMain
class YSAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var driveTopCoordinator : YSDriveTopCoordinator?
    var backgroundSession : URLSession?
    var backgroundSessionCompletionHandler: (() -> Void)?
    var fileDownloader : YSDriveFileDownloader?
//    var databaseManager : YSDatabaseManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
//        GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: YSConstants.kDriveKeychainAuthorizerName)
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        fileDownloader = YSDriveFileDownloader()
//        databaseManager = YSDatabaseManager()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)
    {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    static func appDelegate() -> YSAppDelegate
    {
        return UIApplication.shared.delegate as! YSAppDelegate
    }
}
