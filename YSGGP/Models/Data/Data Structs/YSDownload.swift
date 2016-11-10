//
//  YSDownload.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSDownload : YSDownloadProtocol
{
    var file : YSDriveFileProtocol
    var progressHandler : DownloadFileProgressHandler
    var completionHandler : DownloadCompletionHandler
    var isDownloading : Bool = false
    var progress : Float = 0.0
    
    var downloadTask : Foundation.NSURLSessionDownloadTask?
    var resumeData : Data?
    
    var totalSize : String?
    
    init(file : YSDriveFileProtocol, progressHandler : @escaping DownloadFileProgressHandler, completionHandler : @escaping DownloadCompletionHandler)
    {
        self.file = file
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }
    
    func progressString() -> String
    {
        return String(format: "%.1f%% of %@",  self.progress * 100, totalSize!)
    }
}
