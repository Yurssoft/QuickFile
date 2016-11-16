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
import Firebase

protocol YSAuthenticationCoordinatorDelegate: class
{
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator, error: YSErrorProtocol?)
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
                                                                    
                                                                    
                                                                    let idToken = authResult?.parameters["id_token"] as? String
                                                                    let accessToken = authResult?.parameters["access_token"] as? String
                                                                    
                                                                    if idToken != nil && accessToken != nil
                                                                    {
                                                                        let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken!,
                                                                                                                      accessToken: accessToken!)
                                                                        var storedError: YSErrorProtocol!
                                                                        let downloadGroup = DispatchGroup()
                                                                        downloadGroup.enter()
                                                                        FIRAuth.auth()?.signIn(with: credential)
                                                                        { (user, error) in
                                                                            if let error = error
                                                                            {
                                                                                storedError = YSError(errorType: YSErrorType.couldNotLoginToDrive, messageType: Theme.error, title: "Error", message: "Couldn't login to Database", buttonTitle: "Try Again", debugInfo: error.localizedDescription)
                                                                            }
                                                                            downloadGroup.leave()
                                                                        }
                                                                        let result = downloadGroup.wait(timeout: DispatchTime.distantFuture)
                                                                        switch result
                                                                        {
                                                                        case .success:
                                                                            
                                                                            if storedError != nil
                                                                            {
                                                                                self.dismissAuthentication()
                                                                                {
                                                                                    self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: storedError)
                                                                                }
                                                                                return
                                                                            }
                                                                            
                                                                            break
                                                                        default:
                                                                            break
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        var yserror : YSErrorProtocol
                                                                        yserror = YSError(errorType: YSErrorType.couldNotLoginToDrive, messageType: Theme.error, title: "Error", message: "Couldn't login to Database", buttonTitle: "Try Again", debugInfo: error.debugDescription)
                                                                        self.dismissAuthentication()
                                                                        {
                                                                            self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self, error: yserror)
                                                                        }
                                                                        return
                                                                    }
                                                                    
                                                                    YSDriveManager.shared.authorizer = authResult
                                                                    
                                                                    var yserror : YSErrorProtocol
                                                                    if error == nil && YSDriveManager.shared.isLoggedIn
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
