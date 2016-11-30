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

class YSDriveFileDownloader : NSObject
{
    fileprivate var downloads : [String : YSDownloadProtocol] = [String : YSDownloadProtocol]()
    fileprivate var session : Foundation.URLSession
    fileprivate var sessionQueue : OperationQueue
    
    required override init()
    {
        self.session = Foundation.URLSession()
        sessionQueue = OperationQueue()
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.yurssoft.YSGGP.drive_background_file_downloader_session")
        sessionQueue.qualityOfService = .background
        sessionQueue.name = "drive_background_file_downloader_delegate_queue"
        let backgroundSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: sessionQueue)
        self.session = backgroundSession
    }
    
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
    {
        return downloads[file.fileUrl]
    }
    
    func download(file: YSDriveFileProtocol, _ progressHandler: DownloadFileProgressHandler? = nil, completionHandler : DownloadCompletionHandler? = nil)
    {
        if progressHandler == nil || completionHandler == nil || !file.isAudio
        {
            print("NO HANDLERS OR FILE IS FOLDER!")
            return
        }
        if file.localFileExists()
        {
            print("localFileExists")
            return
        }
        if let download = downloads[file.fileUrl]
        {
            print("already downloading \(download.file.fileName)")
            return
        }
        //FIXME: ADD CHECK FOR INTERNET AND VALID TOKEN AND ADD FILES TO DOWNLOAD QUEUE
        
        var download = YSDownload(file: file, progressHandler: progressHandler!, completionHandler: completionHandler!)
        
        let reqURL = URL.init(string: file.fileUrl)
        var request = URLRequest.init(url: reqURL!)
        YSCredentialManager.shared.addAccessTokenHeaders(request: &request)
        let downloadTask = self.session.downloadTask(with: request)
        downloadTask.taskDescription = UUID().uuidString
        download.downloadTask = downloadTask
        downloads[file.fileUrl] = download
        downloadTask.resume()
    }
    
    func pauseDownloading(file: YSDriveFileProtocol)
    {
        var download = downloads[file.fileUrl]
        if (download?.isDownloading)!
        {
            download?.downloadTask?.cancel()
            { (data) in
                download?.resumeData = data
            }
            download?.isDownloading = false
        }
    }
    
    func cancelDownloading(file: YSDriveFileProtocol)
    {
        if let download = downloads[file.fileUrl]
        {
            download.downloadTask?.cancel()
        }
    }
    
    func resumeDownloading(file: YSDriveFileProtocol)
    {
        var download = downloads[file.fileUrl]
        download?.isDownloading = true
        if let resumeData = download?.resumeData
        {
            download?.downloadTask = session.downloadTask(withResumeData: resumeData)
            download?.downloadTask!.resume()
        }
        else
        {
            let downloadTask = session.downloadTask(with: URL.init(string: file.fileUrl)!)
            download?.downloadTask = downloadTask
            downloadTask.resume()
        }
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
        if let url = downloadTask.originalRequest?.url?.absoluteString, var download = downloads[url]
        {
            if let err = YSNetworkResponseManager.validateDownloadTask(downloadTask.response, error: nil, fileName: download.file.fileName)
            {
                download.completionHandler(download, err)
                downloads[url] = nil
                return
            }
            let fileManager = FileManager.default
            
            try? fileManager.removeItem(at: download.file.localFilePath()!)
            
            do
            {
                try fileManager.copyItem(at: location, to: download.file.localFilePath()!)
                download.file.isFileOnDisk = true
                YSDatabaseManager.update(file: download.file)
            }
            catch let error as NSError
            {
                try? fileManager.removeItem(at: download.file.localFilePath()!)
                print("Could not copy file to disk: \(error.localizedDescription)")
                
                let errorMessage = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.error, title: "Error", message: "Could not copy file \(download.file.fileName)", buttonTitle: "Try again", debugInfo: error.localizedDescription)
                
                download.completionHandler(download, errorMessage)
                downloads[url] = nil
                return
            }
            download.completionHandler(download, nil)
            downloads[url] = nil
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if let url = downloadTask.originalRequest?.url?.absoluteString, var download = downloads[url]
        {
            let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            download.progress = progress
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            download.totalSize = totalSize
            download.isDownloading = true
            downloads[url] = download
            download.progressHandler(download)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        if let error = error, let url = task.originalRequest?.url?.absoluteString, let download = downloads[url]
        {
            if error.localizedDescription.contains("cancelled")
            {
                download.completionHandler(download, nil)
                downloads[download.file.fileUrl] = nil
                return
            }
            var yserror : YSErrorProtocol
            yserror = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.error, title: "Error", message: "Couldn't download \(download.file.fileName)", buttonTitle: "Try Again", debugInfo: error.localizedDescription)
            download.completionHandler(download, yserror)
            downloads[download.file.fileUrl] = nil
        }
    }
}
