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

typealias FilesListMetadataDownloadedCompletionHandler = (_ filesDictionary : [String : Any]?,_ error: YSErrorProtocol?) -> Swift.Void

class YSFilesMetadataDownloader
{
    class func downloadFilesList(for requestURL: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil)
    {
        if !isInternetAvailable()
        {
            let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Warning", message: "Could not get list, no internet", buttonTitle: "Try Again", debugInfo: "no internet")
            completionHandler!(["" : ["": NSNull()]], errorMessage)
            return
        }
        if !YSCredentialManager.shared.isPresentRefreshToken() || !YSCredentialManager.isLoggedIn
        {
            let errorMessage = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Warning", message: "Could not get list, please login", buttonTitle: "Login", debugInfo: "no refresh token or is not logged in")
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
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress)
        {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1)
            { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags)
        {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
