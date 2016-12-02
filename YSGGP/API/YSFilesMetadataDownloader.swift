//
//  YSFilesMetadataDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages
import SystemConfiguration
import ReachabilitySwift

typealias FilesListMetadataDownloadedCompletionHandler = (_ filesDictionary : [String : Any]?,_ error: YSErrorProtocol?) -> Swift.Void
typealias AccessTokenRefreshedCompletionHandler = (_ error: YSErrorProtocol?) -> Swift.Void

class YSFilesMetadataDownloader
{
    class func downloadFilesList(for requestURL: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil)
    {
        if !Reachability()!.isReachable
        {
            let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Warning", message: "Could not get list, no internet", buttonTitle: "Try again", debugInfo: "no internet")
            completionHandler!(["" : ["": NSNull()]], errorMessage)
            return
        }
        if !YSCredentialManager.shared.isPresentRefreshToken() || !YSCredentialManager.isLoggedIn
        {
            let errorMessage = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Warning", message: "Could not get list, please login", buttonTitle: "Login", debugInfo: "no refresh token or is not logged in")
            completionHandler!(["" : ["": NSNull()]], errorMessage)
            return
        }
            let reqURL = URL.init(string: requestURL)
            let request = URLRequest.init(url: reqURL!)
            YSCredentialManager.shared.addAccessTokenHeaders(request)
            {  request, error in
                if var err = error
                {
                    err.update(errorType: .couldNotGetFileList, messageType: .warning, title: "Warning", message: "Could not get file list")
                    completionHandler!(["" : ["": NSNull()]], err)
                    return
                }
                let task = Foundation.URLSession.shared.dataTask(with: request)
                { data, response, error in
                    if var err = YSNetworkResponseManager.validate(response, error: error)
                    {
                        err.update(errorType: .couldNotGetFileList, messageType: .warning, title: "Warning", message: "Could not get file list")
                        completionHandler!(["" : ["": NSNull()]], err)
                        return
                    }
                    let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
                    completionHandler!(dict, nil)
                }
                task.resume()
            }
    }
}
