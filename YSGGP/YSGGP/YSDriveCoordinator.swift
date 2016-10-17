//
//  YSAppCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveCoordinator: YSCoordinatorProtocol
{
    var driveViewController: YSDriveViewController?
    var navigationController: UINavigationController?
    
    init(driveViewController: YSDriveViewController, navigationController: UINavigationController)
    {
        self.driveViewController = driveViewController
        self.navigationController = navigationController
    }
    
    func start()
    {
        let viewModel =  YSDriveViewModel()
        driveViewController?.viewModel = viewModel
        viewModel.model = YSDriveModel()
        viewModel.coordinatorDelegate = self
    }
}

extension YSDriveCoordinator : YSAuthenticationCoordinatorDelegate
{
    func showAuthentication()
    {
        let authenticationCoordinator = YSAuthenticationCoordinator(navigationController: navigationController!)
        authenticationCoordinator.delegate = self
        authenticationCoordinator.start()
    }
    
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator)
    {
        YSDriveManager.sharedInstance.service.authorizer = authenticationCoordinator.authorizer
        start()
    }
}

extension YSDriveCoordinator: YSDriveViewModelCoordinatorDelegate
{
    func driveViewModelDidSelectData(_ viewModel: YSDriveViewModel, data: YSDriveItem)
    {
        
    }

    func driveViewModelDidRequestedLogin()
    {
        showAuthentication()
    }
}
