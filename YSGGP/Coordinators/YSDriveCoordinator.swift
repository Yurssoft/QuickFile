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
    
    func start(error: YSError?)
    {
        let viewModel =  YSDriveViewModel()
        driveViewController?.viewModel = viewModel
        viewModel.model = YSDriveModel()
        viewModel.coordinatorDelegate = self
        if error == nil
        {
            return
        }
        viewModel.viewDelegate?.errorDidChange(viewModel: viewModel, error: error!)
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
    
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator, error: YSError?)
    {
        start(error: error)
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
