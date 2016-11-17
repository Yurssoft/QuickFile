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

class YSCredentialManager
{
    static let shared : YSCredentialManager =
    {
        let instance = YSCredentialManager()
        return instance
    }()
    
    private init()
    {
        let accessToken = YSToken.AccessToken( accessToken : "", tokenType : "", availableTo: Date().addDays(days: -200))
        token = YSToken(refreshToken: "", accessToken: accessToken)
    }
    
    private var token : YSToken
    
    func isValidAccessToken() -> Bool
    {
        let isTokenPresent = !token.accessToken.accessToken.isEmpty
        let isNotTimedOut = token.accessToken.availableTo.isLessThanDate(date: Date())
        return isTokenPresent && isNotTimedOut
    }
    
    func isPresentRefreshToken() -> Bool
    {
        return !token.refreshToken.isEmpty
    }
    
    func setToken(refreshToken : String, accessToken : String, availableTo : Date)
    {
        let accessToken = YSToken.AccessToken( accessToken : accessToken, tokenType : token.accessToken.tokenType, availableTo: availableTo)
        token = YSToken(refreshToken: refreshToken, accessToken: accessToken)
    }
    
    func setToken(tokenType : String, accessToken : String, availableTo : Date)
    {
        let accessToken = YSToken.AccessToken( accessToken : accessToken, tokenType : tokenType, availableTo: availableTo)
        token = YSToken(refreshToken: token.refreshToken, accessToken: accessToken)
    }
    
    func set(tokenType : String)
    {
        token.accessToken.tokenType = tokenType
    }
    
    func tokenDictionaryForRefresh() -> [String : String]
    {
        var dictionary = [String : String]()
        dictionary["refresh_token"] = token.refreshToken
        dictionary["grant_type"] = "refresh_token"
        return dictionary
    }
    
    class var isLoggedIn : Bool
    {
        return GIDSignIn.sharedInstance().currentUser != nil && FIRAuth.auth()!.currentUser != nil && GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    
    class func logOut() throws
    {
        GIDSignIn.sharedInstance().signOut()
        try? FIRAuth.auth()!.signOut()
        let message = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.success, title: "Success", message: "Logged out from Drive", buttonTitle: "Login", debugInfo: "")
        throw message
    }
}
