//
//  YSSettingsCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSSettingsCoordinator: YSCoordinatorProtocol {
    func start(settingsViewController: YSSettingsTableViewController) {
        let viewModel = YSSettingsViewModel()
        settingsViewController.viewModel = viewModel
        viewModel.model = YSSettingsModel()
        viewModel.coordinatorDelegate = self
    }
}

extension YSSettingsCoordinator: YSSettingsCoordinatorDelegate {
    func viewModelSuccessfullyLoggedIn(viewModel: YSSettingsViewModel) {
        if let tababarController = YSAppDelegate.appDelegate().window!.rootViewController as? UITabBarController {
            tababarController.selectedIndex = 0 // go to drive tab
            YSAppDelegate.appDelegate().driveTopCoordinator?.getFilesAfterSuccessLogin()
        }
    }

    func viewModelDidDeleteAllLocalFiles(viewModel: YSSettingsViewModel) {
        YSAppDelegate.appDelegate().playerDelegate?.filesDidChange()
        YSAppDelegate.appDelegate().playlistDelegate?.filesDidChange()
        YSAppDelegate.appDelegate().driveDelegate?.filesDidChange()
    }
}
