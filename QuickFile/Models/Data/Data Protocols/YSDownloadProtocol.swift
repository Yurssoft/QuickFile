//
//  YSDownload.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/26/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

enum YSDownloadStatus {
    case downloading(
        progress : Float
    )
    case pending
    case downloaded
    case downloadError
    case cancelled
}

protocol YSDownloadProtocol {
    var fileDriveIdentifier: String { get set }
    var totalSize: String? { get set }

    var downloadTask: URLSessionDownloadTask? { get set }
    var resumeData: Data? { get set }

    var downloadStatus: YSDownloadStatus { get set }
}
