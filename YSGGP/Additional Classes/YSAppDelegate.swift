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
        getFileContents()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)
    {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func getFileContents()
    {
        let url = String(format: "https://www.googleapis.com/drive/v3/files/%@?alt=media&key=%@", "0B22cjmNI4cZQU0ZUVkFFZDJFMW8", YSConstants.kDriveAPIKey)
        let configuration = URLSessionConfiguration.background(withIdentifier: "1")
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "backgroundSession delegate queue"
        backgroundSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        let request = NSURLRequest(url: NSURL(string: url) as! URL)
        let downloadTask = backgroundSession?.downloadTask(with: request as URLRequest)
        downloadTask?.resume()
    }
}

extension YSAppDelegate: URLSessionDelegate
{
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)
    {
        if let appDelegate = UIApplication.shared.delegate as? YSAppDelegate
        {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler
            {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async
                {
                    completionHandler()
                }
            }
        }
    }
}

extension YSAppDelegate: URLSessionDownloadDelegate
{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
    }
}
