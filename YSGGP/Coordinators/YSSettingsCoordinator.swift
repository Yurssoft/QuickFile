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
    
    init(settingsViewController: YSSettingsTableViewController)
    {
        self.settingsViewController = settingsViewController
    }
    
    func start()
    {
        let viewModel = YSSettingsViewModel()
        settingsViewController?.viewModel = viewModel
        viewModel.model = YSSettingsModel()
        viewModel.coordinatorDelegate = self
    }
}

extension YSSettingsCoordinator : YSSettingsCoordinatorDelegate
{
    func viewModelSuccessfullyLoggedIn(viewModel: YSSettingsViewModel)
    {
        if let tababarController = YSAppDelegate.appDelegate().window!.rootViewController as? UITabBarController
        {
            tababarController.selectedIndex = 0 //drive tab
        }
    }
    
    func viewModelDidDeleteAllLocalFiles(viewModel: YSSettingsViewModel)
    {
        YSAppDelegate.appDelegate().playerDelegate?.filesDidChange()
        YSAppDelegate.appDelegate().playlistDelegate?.filesDidChange()
        YSAppDelegate.appDelegate().driveDelegate?.filesDidChange()
    }
}
