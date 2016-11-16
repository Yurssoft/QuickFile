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
    class func downloadFilesList(for requestURL: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil)
    {
        if YSCredentialManager.shared.isValidAccessToken()
        {
            let reqURL = URL.init(string: requestURL)
            let task = Foundation.URLSession.shared.dataTask(with: reqURL!)
            { data, response, error in
                if let err = YSNetworkResponseManager.validate(response!, error: error)
                {
                    completionHandler!(["" : ["": NSNull()]], err)
                    return
                }
                let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
                completionHandler!(dict, nil)
            }
            task.resume()
        }
        else
        {
            let refreshURL = "www.googleapis.com/oauth2/v4/token"
            var request = URLRequest.init(url: URL.init(string: refreshURL)!)
            request.httpMethod = "POST"
            let postBodyDictionary = YSCredentialManager.shared.tokenDictionaryForRefresh()
            request.httpBody = NSKeyedArchiver.archivedData(withRootObject: postBodyDictionary)
            
            let task = Foundation.URLSession.shared.dataTask(with: request)
            { _, _, _ in
                downloadFilesList(for: requestURL, completionHandler)
            }
            task.resume()
        }
    }
}
