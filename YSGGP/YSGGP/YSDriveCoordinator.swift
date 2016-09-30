//
//  YSAppCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GTMOAuth2
import GoogleAPIClient

protocol YSDriveCoordinatorDelegate: class
{
    func driveCoordinatorDidFinish(listCoordinator: YSDriveCoordinator)
}

class YSDriveCoordinator: YSCoordinator
{
    init(driveViewController: YSDriveViewController, navigationController: UINavigationController)
    {
        self.driveViewController = driveViewController
        self.navigationController = navigationController
    }
    
    weak var delegate: YSDriveCoordinatorDelegate?
    var driveViewController: YSDriveViewController?
    var driveModel: YSDriveModel?
    var navigationController: UINavigationController?
    var authController : GTMOAuth2ViewControllerTouch?
    
    
    func start()
    {
        let viewModel =  YSDriveViewModel()
        viewModel.model = YSDriveModel()
        viewModel.coordinatorDelegate = self
        driveModel = viewModel.model
        driveViewController?.viewModel = viewModel
    }
    
    func authorise () -> Void
    {
        let authController = createAuthoriseController()
        navigationController?.present(authController, animated: true, completion: nil)
    }
    
    @objc func dismissmodalView()
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func createAuthoriseController() -> UIViewController
    {
        let scopeString = YSConstants.kDriveScopes.joined(separator: " ")
        authController =  GTMOAuth2ViewControllerTouch.controller(withScope: scopeString,
                                                                        clientID: YSConstants.kDriveClientID,
                                                                        clientSecret: nil,
                                                                        keychainItemName: YSConstants.kDriveKeychainItemName,
                                                                        completionHandler: { (authController, authResult , error) in
                                                                            
                                                                            
                                                                            if error != nil
                                                                            {
                                                                                self.driveModel?.service.authorizer = nil
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
                                                                                                                            [weak self] in self?.start()
                                                                                                                        }
                                                                                                                })
                                                                                                        }
                                                                                                })
                                                                                        }
                                                                                })
                                                                                alert.addAction(ok)
                                                                                authController?.present(alert, animated: true, completion: nil)
                                                                            }
                                                                            else
                                                                            {
                                                                                DispatchQueue.main.async
                                                                                    {
                                                                                        [weak self] in self?.driveModel?.service.authorizer = authResult
                                                                                        self?.navigationController?.dismiss(animated: true, completion: nil)
                                                                                        self?.start()
                                                                                }
                                                                            }
                                                                            
        }) as! GTMOAuth2ViewControllerTouch?
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(YSDriveCoordinator.cancelSigningIn))
        authController?.navigationItem.leftBarButtonItem = leftButton
        let authNav = UINavigationController(rootViewController: authController!)
        return authNav
    }
    
    @objc func cancelSigningIn()
    {
        navigationController?.dismiss(animated: true, completion: nil)
        authController?.cancelSigningIn()
    }
}

extension YSDriveCoordinator: YSDriveViewModelCoordinatorDelegate
{
    func driveViewModelDidSelectData(_ viewModel: YSDriveViewModel, data: YSDriveItem)
    {
        
    }

    func driveViewModelDidRequestedLogin()
    {
        authorise()
    }
}
