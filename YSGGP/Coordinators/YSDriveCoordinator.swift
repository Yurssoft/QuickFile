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
    internal var driveViewController: YSDriveViewController?
    internal var navigationController: UINavigationController?
    
    init(driveViewController: YSDriveViewController, navigationController: UINavigationController)
    {
        self.driveViewController = driveViewController
        self.navigationController = navigationController
    }
    
    func start()
    {
        let viewModel = YSDriveViewModel()
        driveViewController?.viewModel = viewModel
        viewModel.model = YSDriveModel(folderID: "")
        viewModel.coordinatorDelegate = self
    }
    
    internal func start(error: YSError?)
    {
        let viewModel =  YSDriveViewModel()
        driveViewController?.viewModel = viewModel
        viewModel.model = YSDriveModel(folderID: "")
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
    func driveViewModelDidSelectData(_ viewModel: YSDriveViewModel, file: YSDriveFile)
    {
        let driveTopVC = driveViewController?.storyboard?.instantiateViewController(withIdentifier: YSDriveTopViewController.nameOfClass) as! YSDriveTopViewController
        navigationController?.pushViewController(driveTopVC, animated: true)
    }

    func driveViewModelDidRequestedLogin()
    {
        showAuthentication()
    }
}
