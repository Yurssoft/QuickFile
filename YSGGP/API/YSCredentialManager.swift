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
        print(tokenDictionary)
        self.token = tokenDictionary.toYSToken()
        print(self.token)
    }
    
    private var token : YSToken = YSToken()
    
    func isValidAccessToken() -> Bool
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
    
    func urlForAccessToken() -> URL
    {
        let url = "\(YSConstants.kAccessTokenAPIEndpoint)?client_id=\(YSConstants.kDriveClientID)&refresh_token=\(token.refreshToken)&grant_type=refresh_token"
        return URL.init(string: url)!
    }
    
    func addAccessTokenHeaders( request: inout URLRequest)
    {
        if token.accessTokenTokenType.isEmpty
        {
            request.setValue("Authorization", forHTTPHeaderField: "Bearer \(token.accessToken)")
            print("Request URL:  \(request.url)   Authorization:  Bearer \(token.accessToken)")
        }
        else
        {
            request.setValue("Authorization", forHTTPHeaderField: "\(token.accessTokenTokenType) \(token.accessToken)")
            print("Request URL:  \(request.url)   Authorization:  \(token.accessTokenTokenType) \(token.accessToken)")
        }
    }
    
    class var isLoggedIn : Bool
    {
        // GIDSignIn.sharedInstance().currentUser != nil &&
        let isLoggedIn = GIDSignIn.sharedInstance().currentUser != nil && FIRAuth.auth()!.currentUser != nil
        return isLoggedIn
    }
    
    class func logOut() throws
    {
        GIDSignIn.sharedInstance().signOut()
        try? FIRAuth.auth()!.signOut()
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        keychain[data: YSConstants.kTokenKeychainItemKey] = Data()
        let message = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.success, title: "Success", message: "Logged out from Drive", buttonTitle: "Login", debugInfo: "")
        throw message
    }
}
