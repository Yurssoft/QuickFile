//
//  YSSettingsCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSSettingsCoordinator: YSCoordinatorProtocol
{
    var settingsViewController: YSSettingsTableViewController?
    var navigationController: UINavigationController?
    
    init(settingsViewController: YSSettingsTableViewController, navigationController: UINavigationController)
    {
        self.settingsViewController = settingsViewController
        self.navigationController = navigationController
    }
    
    func start()
    {
        let viewModel =  YSSettingsViewModel()
        settingsViewController?.viewModel = viewModel
        viewModel.model = YSSettingsModel()
        viewModel.coordinatorDelegate = self
    }
}

extension YSSettingsCoordinator : YSAuthenticationCoordinatorDelegate
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

extension YSSettingsCoordinator: YSSettingsViewModelCoordinatorDelegate
{
    func settingsViewModelDidRequestedLogin()
    {
        showAuthentication()
    }
}
