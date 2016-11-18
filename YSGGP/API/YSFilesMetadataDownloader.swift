//
//  YSFilesMetadataDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

typealias FilesListMetadataDownloadedCompletionHandler = (_ filesDictionary : [String : Any]?,_ error: YSErrorProtocol?) -> Swift.Void

class YSFilesMetadataDownloader
{
    class func downloadFilesList(for requestURL: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil)
    {
        //check if no internet return
        if !YSCredentialManager.shared.isPresentRefreshToken() || !YSCredentialManager.isLoggedIn
        {
            let errorMessage = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Warning", message: "Could not get list, please login", buttonTitle: "Login", debugInfo: "")
            completionHandler!(["" : ["": NSNull()]], errorMessage)
            return
        }
        if YSCredentialManager.shared.isValidAccessToken()
        {
            let reqURL = URL.init(string: requestURL)
            var request = URLRequest.init(url: reqURL!)
            YSCredentialManager.shared.addAccessTokenHeaders(request: &request)
            let task = Foundation.URLSession.shared.dataTask(with: request)
            { data, response, error in
                if let err = YSNetworkResponseManager.validate(response, error: error)
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
            var request = URLRequest.init(url: YSCredentialManager.shared.urlForAccessToken())
            request.httpMethod = "POST"
            
            let task = Foundation.URLSession.shared.dataTask(with: request)
            { data, response, error in
                
                if let err = YSNetworkResponseManager.validate(response!, error: error)
                {
                    completionHandler!(["" : ["": NSNull()]], err)
                    return
                }
                let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
                if let accessToken = dict["access_token"] as? String , let tokenType = dict["token_type"] as? String, let expiresIn = dict["expires_in"] as? NSNumber
                {
                    let availableTo = Date().addingTimeInterval(expiresIn.doubleValue)
                    YSCredentialManager.shared.setAccessToken(tokenType: tokenType, accessToken: accessToken, availableTo: availableTo)
                    downloadFilesList(for: requestURL, completionHandler)
                }
            }
            task.resume()
        }
    }
}
