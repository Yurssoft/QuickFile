//
//  YSCredentialManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleSignIn
import Firebase
import SwiftMessages
import KeychainAccess
import ReachabilitySwift

typealias AccessTokenAddedCompletionHandler = (_ request: URLRequest, _ error: YSErrorProtocol?) -> Swift.Void

class YSCredentialManager
{
    static let shared : YSCredentialManager =
    {
        let instance = YSCredentialManager()
        return instance
    }()
    
    private init()
    {
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        let tokenData = keychain[data: YSConstants.kTokenKeychainItemKey]
        if tokenData == nil
        {
            return
        }
        if (tokenData?.isEmpty)!
        {
            return
        }
        let tokenDictionary = NSKeyedUnarchiver.unarchiveObject(with: tokenData!) as! [String : Any]
        self.token = tokenDictionary.toYSToken()
    }
    
    private var token : YSToken = YSToken()
    
    private var isValidAccessToken : Bool
    {
        let isTokenPresent = !token.accessToken.isEmpty
        let isNotTimedOut = token.accessTokenAvailableTo.isLessThanDate(date: Date())
        return isTokenPresent && !isNotTimedOut
    }
    
    func isPresentRefreshToken() -> Bool
    {
        return !token.refreshToken.isEmpty
    }
    
    func setTokens(refreshToken : String, accessToken : String, availableTo : Date)
    {
        token.refreshToken = refreshToken
        token.accessToken = accessToken
        token.accessTokenAvailableTo = availableTo
        saveTokenToKeychain()
    }
    
    func setAccessToken(tokenType : String, accessToken : String, availableTo : Date)
    {
        token.accessTokenTokenType = tokenType
        token.accessToken = accessToken
        token.accessTokenAvailableTo = availableTo
        saveTokenToKeychain()
    }
    
    private func saveTokenToKeychain()
    {
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        let tokenDictionary = token.toDictionary()
        let tokenData = NSKeyedArchiver.archivedData(withRootObject: tokenDictionary)
        keychain[data: YSConstants.kTokenKeychainItemKey] = tokenData
    }
    
    private func urlForAccessToken() -> URL
    {
        let url = "\(YSConstants.kAccessTokenAPIEndpoint)?client_id=\(YSConstants.kDriveClientID)&refresh_token=\(token.refreshToken)&grant_type=refresh_token"
        return URL.init(string: url)!
    }
    
    func addAccessTokenHeaders(_ request: URLRequest, _ completionHandler: @escaping AccessTokenAddedCompletionHandler)
    {
        if !isValidAccessToken
        {
            var requestForToken = URLRequest.init(url: urlForAccessToken())
            requestForToken.httpMethod = "POST"
            
            let task = Foundation.URLSession.shared.dataTask(with: requestForToken)
            { data, response, error in
                
                if let err = YSNetworkResponseManager.validate(response, error: error)
                {
                    completionHandler(request, err)
                    return
                }
                let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
                if let accessToken = dict["access_token"] as? String , let tokenType = dict["token_type"] as? String, let expiresIn = dict["expires_in"] as? NSNumber
                {
                    let availableTo = Date().addingTimeInterval(expiresIn.doubleValue)
                    self.setAccessToken(tokenType: tokenType, accessToken: accessToken, availableTo: availableTo)
                    self.addHeaders(to: request, completionHandler)
                }
            }
            task.resume()
            return
        }
        addHeaders(to: request, completionHandler)
    }
    
    private func addHeaders(to request: URLRequest, _ completionHandler: @escaping AccessTokenAddedCompletionHandler)
    {
        var request = request
        if token.accessTokenTokenType.isEmpty
        {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
            print("Request URL:  \(request.url)   Authorization:  Bearer \(token.accessToken)")
            completionHandler(request, nil)
        }
        else
        {
            request.setValue("\(token.accessTokenTokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
            print("Request URL:  \(request.url)   Authorization:  \(token.accessTokenTokenType) \(token.accessToken)")
            completionHandler(request, nil)
        }
    }
    
    class var isLoggedIn : Bool
    {
        let isLoggedIn = !YSCredentialManager.shared.token.refreshToken.isEmpty && FIRAuth.auth()?.currentUser != nil
        return isLoggedIn
    }
    
    class func logOut() throws
    {
        GIDSignIn.sharedInstance().signOut()
        try? FIRAuth.auth()!.signOut()
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        keychain[data: YSConstants.kTokenKeychainItemKey] = Data()
        shared.token = YSToken()
        let message = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.success, title: "Success", message: "Logged out from Drive", buttonTitle: "Login", debugInfo: "")
        throw message
    }
}
