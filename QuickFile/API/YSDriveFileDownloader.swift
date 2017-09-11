//
//  YSDriveFileDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftMessages
import Firebase
import ReachabilitySwift
import SwiftyBeaver

class YSDriveFileDownloader : NSObject
{
    fileprivate var downloads = [String : YSDownloadProtocol]()
    fileprivate var session : URLSession
    fileprivate var sessionQueue : OperationQueue
    fileprivate var reachability = Reachability()!
    
    required override init()
    {
        session = URLSession()
        sessionQueue = OperationQueue()
        sessionQueue.maxConcurrentOperationCount = 1
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.yurssoft.YSGGP.drive_background_file_downloader_session")
        sessionQueue.qualityOfService = .userInitiated
        sessionQueue.name = "drive_background_file_downloader_delegate_queue"
        let backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: sessionQueue)
        session = backgroundSession
        reachability.whenReachable =
        { reachability in
            self.downloadNextFile()
        }
        try? reachability.startNotifier()
    }
    
    func downloadNextFile()
    {
        let activeDownloads = downloads.values.filter
        {
            if case .downloading(_) = $0.downloadStatus
            {
                return true
            }
            return false
        }
        if downloads.count > 0 && activeDownloads.count == 0, var download = downloads.first?.value
        {
            if case .downloading(_) = download.downloadStatus
            {
                return
            }
            let url = YSDriveFile.fileUrlStatic(fileDriveIdentifier: download.fileDriveIdentifier)
            let reqURL = URL.init(string: url)
            let request = URLRequest.init(url: reqURL!)
            YSCredentialManager.shared.addAccessTokenHeaders(request, YSFilesMetadataDownloader.shared.urlSession)
            {  request, error in
                if error != nil
                {
                    return
                }
                let downloadTask = self.session.downloadTask(with: request)
                download.downloadTask = downloadTask
                downloadTask.taskDescription = download.fileDriveIdentifier
                downloadTask.resume()
                download.downloadStatus = .downloading(progress: 0.0)
                self.downloads[download.fileDriveIdentifier] = download
                YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, nil)
            }
        }
    }
    
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    {
        return downloads[fileDriveIdentifier]
    }
    
    func download(fileDriveIdentifier: String)
    {
        if YSDriveFile.localFileExistsStatic(fileDriveIdentifier: fileDriveIdentifier) || downloads[fileDriveIdentifier] != nil
        {
            let log = SwiftyBeaver.self
            log.error("Error downloading file:  local file exists or file is already in downloading queue")
            return
        }
        var download = YSDownload(fileDriveIdentifier: fileDriveIdentifier)
        download.downloadStatus = .pending
        downloads[fileDriveIdentifier] = download
        YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, nil)
        downloadNextFile()
    }
    
    func cancelDownloading(fileDriveIdentifier: String)
    {
        if let download = downloads[fileDriveIdentifier]
        {
            download.downloadTask?.cancel()
            YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, nil)
            downloads[fileDriveIdentifier] = nil
            downloadNextFile()
        }
    }
    
    func cancelAllDownloads()
    {
        for download in downloads
        {
            download.value.downloadTask?.cancel()
        }
        downloads.removeAll()
        YSAppDelegate.appDelegate().downloadsDelegate?.filesDidChange()
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
        if let currentFileIdentifier = downloadTask.taskDescription, let download = downloads[currentFileIdentifier]
        {
            if let err = YSNetworkResponseManager.validateDownloadTask(downloadTask.response, error: nil, fileName: currentFileIdentifier)
            {
                YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, err)
                downloads[currentFileIdentifier] = nil
                return
            }
            let fileManager = FileManager.default
            let log = SwiftyBeaver.self
            
            do
            {
                try fileManager.removeItem(at: YSDriveFile.localFilePathStatic(fileDriveIdentifier: currentFileIdentifier)!)
            }
            catch let error as NSError
            {
                log.error("Could not delete file from disk: \(error.localizedDescription)")
            }
            
            do
            {
                try fileManager.copyItem(at: location, to: YSDriveFile.localFilePathStatic(fileDriveIdentifier: currentFileIdentifier)!)
                log.info("Copied file to disk")
                YSAppDelegate.appDelegate().filesOnDisk.insert(currentFileIdentifier)
            }
            catch let error as NSError
            {
                try? fileManager.removeItem(at: YSDriveFile.localFilePathStatic(fileDriveIdentifier: currentFileIdentifier)!)
                log.error("Could not copy file to disk: \(error.localizedDescription)")
                
                let errorMessage = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.error, title: "Error", message: "Could not copy file \(currentFileIdentifier)", buttonTitle: "Try again", debugInfo: error.localizedDescription)
                
                YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, errorMessage)
                downloads[currentFileIdentifier] = nil
                return
            }
            
            YSAppDelegate.appDelegate().playlistDelegate?.downloadDidChange(download, nil)
            YSAppDelegate.appDelegate().playerDelegate?.downloadDidChange(download, nil)
            YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, nil)
            downloads[currentFileIdentifier] = nil
            downloadNextFile()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if let currentFileIdentifier = downloadTask.taskDescription, var download = downloads[currentFileIdentifier]
        {
            let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            download.downloadStatus = .downloading(progress: progress)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            download.totalSize = totalSize
            downloads[currentFileIdentifier] = download
            YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, nil)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        if let error = error, let currentFileIdentifier = task.taskDescription, var download = downloads[currentFileIdentifier]
        {
            if error.localizedDescription.contains("cancelled") || error.localizedDescription.contains("connection was lost") || error.localizedDescription.contains("No such file or directory")
            {
                download.downloadStatus = .pending
                downloads[currentFileIdentifier] = download
                downloadNextFile()
                return
            }
            var yserror : YSErrorProtocol
            yserror = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.error, title: "Error", message: "Couldn't download \(currentFileIdentifier)", buttonTitle: "Try Again", debugInfo: error.localizedDescription)
            YSAppDelegate.appDelegate().downloadsDelegate?.downloadDidChange(download, yserror)
            downloads[currentFileIdentifier] = nil
        }
    }
}

