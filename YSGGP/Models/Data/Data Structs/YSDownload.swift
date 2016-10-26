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
    var fileDriveIdentifier : String = ""
    var fileUrl : String
    {
        return String(format: "%@files/%@?alt=media&key=%@", YSConstants.kDriveAPIEndpoint, fileDriveIdentifier, YSConstants.kDriveAPIKey)
    }
    var isDownloading : Bool = false
    var progress : Float = 0.0
    
    var downloadTask : Foundation.NSURLSessionDownloadTask?
    var resumeData : NSData?
    
    init(fileDriveIdentifier : String)
    {
        self.fileDriveIdentifier = fileDriveIdentifier
    }
}
