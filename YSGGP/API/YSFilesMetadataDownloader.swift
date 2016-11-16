//
//  YSFilesMetadataDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias FilesListMetadataDownloadedCompletionHandler = (_ filesDictionary : [String : [String: Any]]?,_ error: YSErrorProtocol?) -> Swift.Void

class YSFilesMetadataDownloader
{
    static func downloadFilesList(for requestURL: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil)
    {
        let reqURL = URL.init(string: requestURL)
        let task = Foundation.URLSession.shared.dataTask(with: reqURL!)
        { data, response, error in
            
        }
        task.resume()
    }
}
