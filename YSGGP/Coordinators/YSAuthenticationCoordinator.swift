//
//  YSAuthenticationCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/3/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GTMOAuth2
import GoogleAPIClient
import SwiftMessages

protocol YSAuthenticationCoordinatorDelegate: class
{
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator, error: YSError?)
}

class YSAuthenticationCoordinator: YSCoordinatorProtocol
{
    weak var delegate : YSAuthenticationCoordinatorDelegate?
    var navigationController: UINavigationController?
    var authController : GTMOAuth2ViewControllerTouch?
    
    init(navigationController: UINavigationController)
    {
        self.navigationController = navigationController
    }
    
    func start()
    {
        let authController = createAuthoriseController()
        navigationController?.present(authController, animated: true, completion: nil)
    }
    
    func createAuthoriseController() -> UIViewController
    {
        let scopeString = YSConstants.kDriveScopes.joined(separator: " ")
        authController =  GTMOAuth2ViewControllerTouch.controller(withScope: scopeString,
                                                                  clientID: YSConstants.kDriveClientID,
                                                                  clientSecret: nil,
                                                                  keychainItemName: YSConstants.kDriveKeychainItemName,
                                                                  completionHandler: { (authController, authResult , error) in
                                                                    
                                                                    self.saveAuthResult(authResult: authResult)
                                                                    
                                                                    if error != nil
                                                                    {
                                                                        self.showError(error: error)
                                                                    }
                                                                    else
                                                                    {
                                                                        self.dismissAuthentication()
                                                                        {
                                                                            let error = YSError(errorType: YSErrorType.loggedInToToDrive, messageType: Theme.success, title: "Success", message: "Successfully logged in to Drive", buttonTitle: "Got It")
                                                                            self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: error)
                                                                        }
                                                                    }
        }) as! GTMOAuth2ViewControllerTouch?
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(YSAuthenticationCoordinator.cancelSigningIn))
        authController?.navigationItem.leftBarButtonItem = leftButton
        let authNav = UINavigationController(rootViewController: authController!)
        return authNav
    }
    
    func showError(error : Error?)
    {
        YSDriveManager.sharedInstance.service.authorizer = nil
        dismissAuthentication()
        {
            let error = YSError(errorType: YSErrorType.cancelledLoginToDrive, messageType: Theme.info, title: "Cancelled", message: "Cancelled login to Drive", buttonTitle: "Login")
            self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: error)
        }
    }
    
    func saveAuthResult(authResult : GTMOAuth2Authentication?)
    {
        guard let auth = authResult
        else
        {
            return
        }
        GTMOAuth2ViewControllerTouch.saveParamsToKeychain(forName: YSConstants.kDriveKeychainItemName, authentication: auth)
        YSDriveManager.sharedInstance.service.authorizer = auth
    }
    
    @objc func cancelSigningIn()
    {
        authController?.cancelSigningIn()
        dismissAuthentication()
            {
                let error = YSError(errorType: YSErrorType.cancelledLoginToDrive, messageType: Theme.info, title: "Cancelled", message: "Cancelled login to Drive", buttonTitle: "Login")
            self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: error)
        }
    }
    
    func dismissAuthentication(_ completionHandler: (() -> Swift.Void)? = nil)
    {
        DispatchQueue.main.async
        {
            self.navigationController?.dismiss(animated: false, completion:
            {
            })
            
            self.navigationController?.dismiss(animated: false, completion:
            {
            })
            if completionHandler != nil
            {
                completionHandler!()
            }
        }
    }
}
