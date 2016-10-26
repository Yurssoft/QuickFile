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
    var fileDriveIdentifier : String { get }
    var fileUrl : String { get }
    var isDownloading : Bool { get set }
    var progress : Float { get set }
    
    var downloadTask : Foundation.NSURLSessionDownloadTask? { get set }
    var resumeData : NSData? { get set }
}
