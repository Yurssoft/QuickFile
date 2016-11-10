//
//  YSDownload.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDownloadProtocol
{
    var file : YSDriveFileProtocol { get set}
    var isDownloading : Bool { get set }
    var progress : Float { get set }
    var totalSize : String? { get set }
    
    var downloadTask : Foundation.NSURLSessionDownloadTask? { get set }
    var resumeData : Data? { get set }
    
    var progressHandler : DownloadFileProgressHandler { get set }
    var completionHandler : DownloadCompletionHandler { get set }
    
    func progressString() -> String
}
