//
//  AppDelegate.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GTMOAuth2
import Firebase
import GoogleSignIn
import NSLogger
import UserNotifications
import SafariServices
import Reqres

protocol YSUpdatingDelegate: class
{
    func downloadDidChange(_ download : YSDownloadProtocol,_ error: YSErrorProtocol?)
    func filesDidChange()
}

//TODO: search add loading indicator, show all downloads in playlist, logged as, download wifi only (allowsCellularAccess), memory leaks, firebase functions?, folders leaks, add spotlight search, add search in playlist, use codable instead of reflection, delete played files after 24 hours, display all files in drive and use document previewer for all files, when downloading files and token dies - refresh it, what happens when no storage, make downloads in order

@UIApplicationMain
class YSAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var driveTopCoordinator : YSDriveTopCoordinator?
    var searchCoordinator : YSDriveSearchCoordinator?
    var playerCoordinator = YSPlayerCoordinator()
    var settingsCoordinator = YSSettingsCoordinator()
    var playlistCoordinator = YSPlaylistCoordinator()
    var backgroundSession : URLSession?
    var backgroundSessionCompletionHandler: (() -> Void)?
    var fileDownloader : YSDriveFileDownloader = YSDriveFileDownloader()
    var filesOnDisk = Set<String>()
    
    weak var downloadsDelegate: YSUpdatingDelegate?
    weak var playlistDelegate: YSUpdatingDelegate?
    weak var playerDelegate: YSUpdatingDelegate?
    weak var driveDelegate: YSUpdatingDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        //logs
        Reqres.logger = ReqresDefaultLogger()
        Reqres.register()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: YSConstants.kDefaultBlueColor], for:.selected)
        UITabBar.appearance().tintColor = YSConstants.kDefaultBlueColor
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().signInSilently()
        
        Log(.App, .Info, "FIRApp, GIDSignIn - configured")
        
        lookUpAllFilesOnDisk()
        
        Log(.App, .Info, "looked Up All Files On Disk")
        
//        YSDatabaseManager.deleteDatabase { (error) in
//            //TODO: REMOVES DATABASE
//            log.error("DATABASE DELETED")
//            log.error("DATABASE DELETED")
//            log.error("DATABASE DELETED")
//            let when = DispatchTime.now() + 3
//            DispatchQueue.main.asyncAfter(deadline: when)
//            {
//                self.driveDelegate?.filesDidChange()
//            }
//        }
        
        Log(.App, .Info, "Register for notifications")
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: { (granted, error) in
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                application.registerForRemoteNotifications()
            }
        })
        Log(.App, .Info, "Finished registering for notifications")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)
    {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Log(.App, .Info, "")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Log(.App, .Info, "")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Log(.App, .Info, "")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Log(.App, .Info, "")
    }
    
    class func appDelegate() -> YSAppDelegate
    {
        return UIApplication.shared.delegate as! YSAppDelegate
    }
    
    private func lookUpAllFilesOnDisk()
    {
        filesOnDisk = YSDatabaseManager.getAllFileNamesOnDisk()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        Log(.App, .Info, "Successfully registered for notifications. Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log(.App, .Info, "Failed to register: \(error)")
    }
    
//    {
//    "aps": {
//    "content-available": 0
//    }
//    }
    //recieves remote silent notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        Log(.App, .Info, "Recieved remote silent notification: \(aps)")
        if aps["content-available"] as? Int == 1 {
            completionHandler(.newData)
        } else {
            completionHandler(.newData)
        }
    }
}

extension YSAppDelegate : UNUserNotificationCenterDelegate
{
//    {
//    "aps": {
//    "alert": "New version!",
//    "sound": "default",
//    "link_url": "https://github.com/Yurssoft/QuickFile"
//    }
//    }
    //recieves push notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        Log(.App, .Info, "Recieved push notification: \(response.notification.request.content.userInfo)")
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        if let urlString = aps["link_url"], let url = URL(string: urlString as! String)
        {
            let safari = SFSafariViewController(url: url)
            window?.rootViewController?.present(safari, animated: true, completion: nil)
        }
        
        completionHandler()
    }
}
