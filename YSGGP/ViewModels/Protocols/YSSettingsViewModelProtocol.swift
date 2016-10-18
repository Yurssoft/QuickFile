//
//  YSSettingsViewModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSSettingsViewModelViewDelegate: class
{
    func errorDidChange(viewModel: YSSettingsViewModel, error: YSError)
}

protocol YSSettingsViewModelCoordinatorDelegate: class
{
    func settingsViewModelDidRequestedLogin()
}

protocol YSSettingsViewModelProtocol
{
    var isLoggedIn : Bool {get}

    func loginToDrive()
    func logOut()
}
