//
//  YSDownload.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

enum YSDownloadStatus
{
    case downloading(
        progress : Float
    )
    case pending
}

protocol YSDownloadProtocol
{
    var file : YSDriveFileProtocol { get set}
    var totalSize : String? { get set }
    
    var downloadTask : Foundation.NSURLSessionDownloadTask? { get set }
    var resumeData : Data? { get set }
    
    var progressHandler : DownloadFileProgressHandler { get set }
    var completionHandler : DownloadCompletionHandler { get set }
    var downloadStatus : YSDownloadStatus { get set }
}
