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
    
    var downloadTask : URLSessionDownloadTask?
    var resumeData : Data?
    
    var totalSize : String?
    
    internal var downloadStatus : YSDownloadStatus = .pending
    
    init(file : YSDriveFileProtocol)
    {
        self.file = file
    }
}
