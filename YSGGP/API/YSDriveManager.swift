//
//  YSDriveManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GTMOAuth2
import SwiftMessages

class YSDriveManager
{
    static let sharedInstance : YSDriveManager =
    {
        let instance = YSDriveManager()
        instance.login()
        return instance
    }()
    
    func login()
    {
        let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName:  YSConstants.kDriveKeychainAuthorizerName,
            clientID: YSConstants.kDriveClientID,
            clientSecret: nil)
        do
        {
            try GTMOAuth2ViewControllerTouch.authorizeFromKeychain(forName:YSConstants.kDriveKeychainAuthorizerName, authentication: auth)
        }
        catch
        {
            print("Error login to drive:       \(error.localizedDescription)")
        }
        service.authorizer = auth
    }
    
    let service = GTLRDriveService()
    
    var isLoggedIn : Bool
    {
        return service.authorizer != nil && service.authorizer!.canAuthorize!
    }
    
    var authorizer: GTMFetcherAuthorizationProtocol!
    {
        didSet
        {
            if authorizer != nil
            {
                GTMOAuth2ViewControllerTouch.saveParamsToKeychain(forName: YSConstants.kDriveKeychainAuthorizerName, authentication: authorizer as! GTMOAuth2Authentication!)
                service.authorizer = authorizer
                login()
            }
        }
    }
    
    func logOut() throws
    {
        if GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: YSConstants.kDriveKeychainAuthorizerName)
        {
            YSDriveManager.sharedInstance.service.authorizer = nil
            let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.success, title: "Success", message: "Successfully logged out from Drive", buttonTitle: "Login")
            throw error
        }
        else
        {
            let error = YSError(errorType: YSErrorType.couldNotLogOutFromDrive, messageType: Theme.error, title: "Error", message: "Couldn't remove saved data from keychain", buttonTitle: "Try again")
            throw error
        }
    }
}
