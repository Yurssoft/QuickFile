//
//  YSDriveFileDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftMessages

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
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "drive_background_file_downloader_session")
        sessionQueue.maxConcurrentOperationCount = 1
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
        //if file is folder
        if progressHandler == nil || completionHandler == nil || !file.isAudio
        {
            print("NO HANDLERS OR FILE IS FOLDER!")
            return
        }
        if file.localFileExists()
        {
            print("localFileExists")
            //return
        }
        var download = YSDownload(file: file, progressHandler: progressHandler!, completionHandler: completionHandler!)
        let downloadTask = session.downloadTask(with: URL.init(string: file.fileUrl)!)
        downloadTask.taskDescription = UUID().uuidString
        download.downloadTask = downloadTask
        download.isDownloading = true
        downloads[file.fileUrl] = download
        downloadTask.resume()
        download.progressHandler(download)
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
        var download = downloads[file.fileUrl]
        download?.downloadTask?.cancel()
        downloads[file.fileUrl] = nil
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
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
            download.completionHandler(download, nil)
            downloads[url] = nil
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if let url = downloadTask.originalRequest?.url?.absoluteString, var download = downloads[url]
        {
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            download.totalSize = totalSize
            download.progressHandler(download)
            print("Progress \(download.progressString())")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        if let url = task.originalRequest?.url?.absoluteString, let download = downloads[url]
        {
            var yserror : YSErrorProtocol
            yserror = YSError(errorType: YSErrorType.couldNotLoginToDrive, messageType: Theme.error, title: "Error", message: "Couldn't download \(download.file.fileName)", buttonTitle: "Try Again", debugInfo: error.debugDescription)
            download.completionHandler(download, yserror)
        }
    }
}
