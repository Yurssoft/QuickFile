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
    private let service = GTLServiceDrive()
    
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
    
    func createAuthController(_ completionhandler: @escaping () -> Void) -> GTMOAuth2ViewControllerTouch
    {
        let scopeString = YSConstants.kDriveScopes.joined(separator: " ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: YSConstants.kDriveClientID,
            clientSecret: nil,
            keychainItemName: YSConstants.kDriveKeychainItemName,
            delegate: self,
            finishedSelector: #selector(YSDriveModel.viewController(vc:finishedWithAuth:error:))
        )
    }
    
    @objc func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication,
                        error : NSError?)
    {
        
        if let error = error
        {
            service.authorizer = nil
            print("Authentication Error \(error.localizedDescription)")
        }
        service.authorizer = authResult
//        dismissViewControllerAnimated(true, completion: nil)
    }
}
