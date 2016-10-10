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

protocol YSAuthenticationCoordinatorDelegate: class
{
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator)
}

class YSAuthenticationCoordinator: YSCoordinatorProtocol
{
    weak var delegate : YSAuthenticationCoordinatorDelegate?
    var navigationController: UINavigationController?
    var authController : GTMOAuth2ViewControllerTouch?
    var authorizer: GTMOAuth2Authentication?
    
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
                                                                        DispatchQueue.main.async
                                                                        {
                                                                            self.authorizer = authResult
                                                                            self.navigationController?.dismiss(animated: true, completion:
                                                                                {
                                                                                    DispatchQueue.main.async
                                                                                    {
                                                                                        self.navigationController?.dismiss(animated: true, completion:
                                                                                        {
                                                                                            DispatchQueue.main.async
                                                                                            {
                                                                                                self.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self)
                                                                                            }
                                                                                        })
                                                                                    }
                                                                            })
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
        self.authorizer = nil
        let alert = UIAlertController(
            title: "Authentication Error",
            message: error?.localizedDescription,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
            { (UIAlertAction) in
                DispatchQueue.main.async
                {
                    [weak self] in self?.navigationController?.dismiss(animated: true, completion:
                    {
                        DispatchQueue.main.async
                        {
                            [weak self] in self?.navigationController?.dismiss(animated: true, completion:
                            {
                                DispatchQueue.main.async
                                {
                                    [weak self] in self?.delegate?.authenticationCoordinatorDidFinish(authenticationCoordinator: self!)
                                }
                            })
                        }
                    })
            }
        })
        alert.addAction(ok)
        authController?.present(alert, animated: true, completion: nil)
    }
    
    func saveAuthResult(authResult : GTMOAuth2Authentication?)
    {
        guard let auth = authResult
        else
        {
            return
        }
        GTMOAuth2ViewControllerTouch.saveParamsToKeychain(forName: YSConstants.kDriveKeychainItemName, authentication: auth)
    }
    
    @objc func cancelSigningIn()
    {
        navigationController?.dismiss(animated: true, completion: nil)
        authController?.cancelSigningIn()
    }
}
