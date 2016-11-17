//
//  YSFilesMetadataDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

typealias FilesListMetadataDownloadedCompletionHandler = (_ filesDictionary : [String : [String: Any]]?,_ error: YSErrorProtocol?) -> Swift.Void

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
            let refreshURL = "https://www.googleapis.com/oauth2/v4/token"
            var request = URLRequest.init(url: URL.init(string: refreshURL)!)
            request.httpMethod = "POST"
            let postBodyDictionary = YSCredentialManager.shared.tokenDictionaryForRefresh()
            request.httpBody = NSKeyedArchiver.archivedData(withRootObject: postBodyDictionary)
            
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
                    YSCredentialManager.shared.setToken(tokenType: tokenType, accessToken: accessToken, availableTo: availableTo)
                }
            }
            task.resume()
        }
    }
}
