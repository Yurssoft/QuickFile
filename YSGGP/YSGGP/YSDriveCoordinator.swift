//
//  YSAppCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

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
        let authNavigationController = YSNavigationController(rootViewController: authController)
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissmodalView))
        authController.navigationItem.leftBarButtonItem = leftButton
        navigationController?.present(authNavigationController, animated: true, completion: nil)
    }
    
    @objc func dismissmodalView()
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func createAuthoriseController() -> GTMOAuth2ViewControllerTouch
    {
        let scopeString = YSConstants.kDriveScopes.joined(separator: " ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: YSConstants.kDriveClientID,
            clientSecret: nil,
            keychainItemName: YSConstants.kDriveKeychainItemName,
            delegate: self,
            finishedSelector: Selector(("viewController:finishedWithAuth:error:"))
        )
    }
    
    @objc func viewController(vc : UIViewController, finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?)
    {
        if error != nil
        {
            driveModel?.service.authorizer = nil
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
            navigationController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            driveModel?.service.authorizer = authResult
            navigationController?.dismiss(animated: true, completion: nil)
            start()
        }
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
