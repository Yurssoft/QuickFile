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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
//        GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: YSConstants.kDriveKeychainAuthorizerName)
        FIRApp.configure()
        
//        if (FIRAuth.auth()?.currentUser) != nil
//        {
//            var ref: FIRDatabaseReference!
//            
//            ref = FIRDatabase.database().reference()
//            let user = "user1"
//            ref.setValue(user)
//            ref.child("user1/username").setValue("someUsername")
//            
//            ref.child("user1").observeSingleEvent(of: .value, with: { (snapshot) in
//                // Get user value
//                let value = snapshot.value as? NSDictionary
//                print(value)
//                // ...
//            }) { (error) in
//                print(error.localizedDescription)
//            }
//            
//            
//        } else {
//            // No user is signed in.
//        }
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)
    {
        backgroundSessionCompletionHandler = completionHandler
    }
}
