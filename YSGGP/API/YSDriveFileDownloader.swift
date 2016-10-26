//
//  YSDriveFileDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveFileDownloader : NSObject
{
    fileprivate var downloads : [YSDownloadProtocol] = []
    fileprivate var session : Foundation.URLSession
    
    static let shared : YSDriveFileDownloader =
    {
        return YSDriveFileDownloader()
    }()
    
    private override init()
    {
        self.session = Foundation.URLSession()
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "drive_background_file_downloader_session")
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        queue.name = "drive_background_file_downloader_delegate_queue"
        let backgroundSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        self.session = backgroundSession
    }
    
    func downloadFile(fileID: String)
    {
        let download = YSDownload(fileDriveIdentifier: fileID)
        
    }
    
    func localFilePath(for fileID: String) -> NSURL?
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        if let url = NSURL(string: fileID), let lastPathComponent = url.lastPathComponent
        {
            let fullPath = documentsPath.appendingPathComponent(lastPathComponent)
            return NSURL(fileURLWithPath:fullPath)
        }
        return nil
    }
    
    func localFileExists(at localFilePath: NSURL) -> Bool
    {
        var isDir : ObjCBool = false
        if let path = localFilePath.path
        {
            return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        }
        return false
    }
    
}

extension YSDriveFileDownloader: URLSessionDelegate
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

extension YSDriveFileDownloader: URLSessionDownloadDelegate
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
