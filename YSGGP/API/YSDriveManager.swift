//
//  YSDriveManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClient
import GTMOAuth2

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
            forName:  YSConstants.kDriveKeychainItemName,
            clientID: YSConstants.kDriveClientID,
            clientSecret: nil)
        do
        {
            try GTMOAuth2ViewControllerTouch.authorizeFromKeychain(forName:YSConstants.kDriveKeychainItemName, authentication: auth)
        }
        catch
        {
            print("Error login to drive:       \(error.localizedDescription)")
        }
        service.authorizer = auth
    }
    
    let service = GTLServiceDrive()
    
    var isLoggedIn : Bool
    {
        return service.authorizer != nil && service.authorizer.canAuthorize!
    }
    
    func logOut() throws
    {
        if GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: YSConstants.kDriveKeychainItemName)
        {
            YSDriveManager.sharedInstance.service.authorizer = nil
        }
        else
        {
            throw YSError(errorType: YSErrorType.couldNotLogOutFromDrive, message: "Couldn't remove saved data from keychain")
        }
    }
}
