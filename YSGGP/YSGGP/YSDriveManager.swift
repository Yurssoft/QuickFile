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
        return instance
    }()
    
    let service = GTLServiceDrive()
    
    var isLoggedIn : Bool
    {
        return service.authorizer != nil
    }
    
    func logOut() throws
    {
        if GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: YSConstants.kDriveKeychainItemName)
        {
            YSDriveManager.sharedInstance.service.authorizer = nil
        }
        else
        {
            throw YSError.couldNotLogOutFromDrive
        }
    }
}
