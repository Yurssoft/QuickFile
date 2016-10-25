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
    fileprivate var settingsViewController: YSSettingsTableViewController?
    fileprivate var navigationController: UINavigationController?
    
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
    
    
    fileprivate func start(error: YSError?)
    {
        let viewModel =  YSSettingsViewModel()
        settingsViewController?.viewModel = viewModel
        viewModel.model = YSSettingsModel()
        viewModel.coordinatorDelegate = self
        if error == nil
        {
            return
        }
        viewModel.viewDelegate?.errorDidChange(viewModel: viewModel, error: error!)
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
    
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator, error: YSError?)
    {
        start(error:error)
    }
}

extension YSSettingsCoordinator: YSSettingsViewModelCoordinatorDelegate
{
    func settingsViewModelDidRequestedLogin()
    {
        showAuthentication()
    }
}
