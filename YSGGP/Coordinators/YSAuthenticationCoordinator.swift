//
//  YSAuthenticationCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/3/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GTMOAuth2
import SwiftMessages

protocol YSAuthenticationCoordinatorDelegate: class
{
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator, error: YSError?)
}

class YSAuthenticationCoordinator: YSCoordinatorProtocol
{
    weak var delegate : YSAuthenticationCoordinatorDelegate?
    fileprivate var navigationController: UINavigationController?
    fileprivate var authController : GTMOAuth2ViewControllerTouch?
    
    init(navigationController: UINavigationController)
    {
        self.navigationController = navigationController
    }
    
    func start()
    {
        let authController = createAuthoriseController()
        navigationController?.present(authController, animated: true, completion: nil)
    }
    
    fileprivate func createAuthoriseController() -> UIViewController
    {
        let scopeString = YSConstants.kDriveScopes.joined(separator: " ")
        authController =  GTMOAuth2ViewControllerTouch.controller(withScope: scopeString,
                                                                  clientID: YSConstants.kDriveClientID,
                                                                  clientSecret: nil,
                                                                  keychainItemName: YSConstants.kDriveKeychainAuthorizerName,
                                                                  completionHandler: { (authController, authResult , error) in
                                                                    
                                                                    YSDriveManager.sharedInstance.authorizer = authResult
                                                                    
                                                                    var yserror : YSError
                                                                    if error == nil && YSDriveManager.sharedInstance.isLoggedIn
                                                                    {
                                                                        yserror = YSError(errorType: YSErrorType.loggedInToToDrive, messageType: Theme.success, title: "Success", message: "Successfully logged in to Drive", buttonTitle: "Got It")
                                                                    }
                                                                    else
                                                                    {
                                                                        yserror = YSError(errorType: YSErrorType.couldNotLoginToDrive, messageType: Theme.error, title: "Error", message: "Couldn't login to Drive", buttonTitle: "Try Again", debugInfo: error.debugDescription)
                                                                    }
                                                                    self.dismissAuthentication()
                                                                    {
                                                                        self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: yserror)
                                                                    }
        }) as! GTMOAuth2ViewControllerTouch?
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(YSAuthenticationCoordinator.cancelSigningIn))
        authController?.navigationItem.leftBarButtonItem = leftButton
        let authNav = UINavigationController(rootViewController: authController!)
        return authNav
    }
    
    @objc fileprivate func cancelSigningIn()
    {
        authController?.cancelSigningIn()
        dismissAuthentication()
        {
            let error = YSError(errorType: YSErrorType.cancelledLoginToDrive, messageType: Theme.info, title: "Cancelled", message: "Cancelled login to Drive", buttonTitle: "Login")
            self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: error)
        }
    }
    
    fileprivate func dismissAuthentication(_ completionHandler: (() -> Swift.Void)? = nil)
    {
        DispatchQueue.main.async
        {
            self.navigationController?.dismiss(animated: false)
            self.navigationController?.dismiss(animated: false)
            if completionHandler != nil
            {
                completionHandler!()
            }
        }
    }
}
