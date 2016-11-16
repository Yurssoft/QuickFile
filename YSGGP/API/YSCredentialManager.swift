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

class YSCredentialManager
{
    static let shared : YSCredentialManager =
    {
        let instance = YSCredentialManager()
        return instance
    }()
    
    private init()
    {
        let refreshToken = YSToken.RefreshToken( refreshToken : "", clientID : "")
        let accessToken = YSToken.AccessToken( accessToken : "", tokenType : "", availableTo: Date().addDays(days: -200))
        token = YSToken(refreshToken: refreshToken, accessToken: accessToken)
    }
    
    private var token : YSToken
    
    func isValidAccessToken() -> Bool
    {
        let isTokenPresent = !token.accessToken.accessToken.isEmpty
        let isNotTimedOut = token.accessToken.availableTo.isLessThanDate(date: Date())
        return isTokenPresent && isNotTimedOut
    }
    
    func setToken(refreshToken : String, accessToken : String, availableTo : Date)
    {
        let refreshToken = YSToken.RefreshToken( refreshToken : refreshToken, clientID : token.refreshToken.clientID)
        let accessToken = YSToken.AccessToken( accessToken : accessToken, tokenType : token.accessToken.tokenType, availableTo: availableTo)
        token = YSToken(refreshToken: refreshToken, accessToken: accessToken)
    }
    
    func set(clientID : String)
    {
        token.refreshToken.clientID = clientID
    }
    
    func set(tokenType : String)
    {
        token.accessToken.tokenType = tokenType
    }
    
    func tokenDictionaryForRefresh() -> [String : String]
    {
        var dictionary = [String : String]()
        dictionary["client_id"] = token.refreshToken.clientID
        dictionary["refresh_token"] = token.refreshToken.refreshToken
        dictionary["grant_type"] = "refresh_token"
        return dictionary
    }
    
    class var isLoggedIn : Bool
    {
        return GIDSignIn.sharedInstance().currentUser != nil && FIRAuth.auth()!.currentUser != nil
    }
    
    class func logOut()
    {
        GIDSignIn.sharedInstance().signOut()
        try? FIRAuth.auth()!.signOut()
    }
}
