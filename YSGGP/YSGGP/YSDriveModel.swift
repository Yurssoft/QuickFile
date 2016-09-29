//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClient
import GTMOAuth2

class YSDriveModel: YSDriveModelProtocol
{
    var isLoggedIn : Bool
    {
        return service.authorizer != nil
    }
    let service = GTLServiceDrive()
    
    func items(_ completionhandler: @escaping (_ items: [YSDriveItem]) -> Void)
    {
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName:  YSConstants.kDriveKeychainItemName,
            clientID: YSConstants.kDriveClientID,
            clientSecret: nil)
        {
            service.authorizer = auth
        }
        else
        {
            print("login to drive first!")
        }
    }
}
