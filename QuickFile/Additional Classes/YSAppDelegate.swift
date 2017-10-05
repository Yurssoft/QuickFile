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

/* TODO:
 - search add loading indicator
 - show all downloads in playlist
 - logged as
 - download wifi only (allowsCellularAccess)
 - firebase functions?
 - add spotlight search
 - add search in playlist
 - use codable instead of reflection
 - delete played files after 24 hours
 - display all files in drive and use document previewer for all files
 - what happens when no storage
 - make downloads in order
 - add tutorial screen
 - battery life
 */

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
    
    override init()
    {
        super.init()
        UIViewController.classInit
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        startNSLogger()
        Reqres.logger = ReqresDefaultLogger()
        Reqres.register()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: YSConstants.kDefaultBlueColor], for:.selected)
        UITabBar.appearance().tintColor = YSConstants.kDefaultBlueColor
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().signInSilently()
        
        LogDefault(.App, .Info, "FIRApp, GIDSignIn - configured")
        
        lookUpAllFilesOnDisk()
        
        LogDefault(.App, .Info, "looked Up All Files On Disk")
        
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
        
        LogDefault(.App, .Info, "Register for notifications")
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: { (granted, error) in
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async
                {
                    application.registerForRemoteNotifications()
                }
            }
        })
        LogDefault(.App, .Info, "Finished registering for notifications")
        return true
    }
    
    private func startNSLogger()
    {
        let logsDirectory = YSConstants.logsFolder
        do
        {
            try FileManager.default.createDirectory(atPath: logsDirectory.relativePath, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            LogDefault(.App, .Error, "Error creating directory: \(error.localizedDescription)")
        }
        removeOldestLogIfNeeded()
        
        let file = "\(logsDirectory.relativePath)/NSLoggerData-" + UUID().uuidString + ".rawnsloggerdata"
        LoggerSetBufferFile(nil, file as CFString)
        
        LoggerSetOptions(nil, UInt32(kLoggerOption_BufferLogsUntilConnection | kLoggerOption_BrowseBonjour | kLoggerOption_BrowseOnlyLocalDomain))
        
        let bundleName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
        LoggerSetupBonjour(nil, nil, bundleName as CFString)
        LoggerStart(nil)
    }
    
    private func removeOldestLogIfNeeded()
    {
        DispatchQueue.global(qos: .utility).async
        {
            LogDefault(.App, .Info, "removeOldestLogIfNeeded")
            do
            {
                let urlArray = try FileManager.default.contentsOfDirectory(at: YSConstants.logsFolder, includingPropertiesForKeys: [.contentModificationDateKey], options:.skipsHiddenFiles)
                if urlArray.count > YSConstants.kNumberOfLogsStored
                {
                    let fileUrlsSortedByDate = urlArray.map { url in
                        (url, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                        }
                        .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                        .map { $0.0 } // extract file urls
                    if let oldestLogFileUrl = fileUrlsSortedByDate.last
                    {
                        try FileManager.default.removeItem(at: oldestLogFileUrl) // we delete the oldest log
                        LogDefault(.App, .Info, "Removed oldest log: " + oldestLogFileUrl.relativePath)
                    }
                }
            }
            catch let error as NSError
            {
                LogDefault(.App, .Error, "Error while working with logs folder contents \(error.localizedDescription)")
            }
        }
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
        LogDefault(.App, .Info, "")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        LogDefault(.App, .Info, "")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        LogDefault(.App, .Info, "")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        LogDefault(.App, .Info, "")
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
        LogDefault(.App, .Info, "Successfully registered for notifications. Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LogDefault(.App, .Info, "Failed to register: \(error)")
    }
    
//    {
//    "aps": {
//    "content-available": 0
//    }
//    }
    //recieves remote silent notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        LogDefault(.App, .Info, "Recieved remote silent notification: \(aps)")
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
        LogDefault(.App, .Info, "Recieved push notification: \(response.notification.request.content.userInfo)")
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
