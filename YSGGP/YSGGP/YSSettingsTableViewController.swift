//
//  YSSettingsViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/21/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftMessages

class YSSettingsTableViewController: UITableViewController
{
    var viewModel : YSSettingsViewModel?
    {
        willSet
        {
            viewModel?.viewDelegate = nil
        }
        didSet
        {
            viewModel?.viewDelegate = self
            if isViewLoaded
            {
                tableView.reloadData()
            }
        }
    }
    let cellLogInOutIdentifier = "logInOutCell"
    let cellLogInOutInfoIdentifier = "loggedInOutInfoCell"
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        switch cell.reuseIdentifier!
        {
            case cellLogInOutInfoIdentifier:
                cell.textLabel?.text = (viewModel?.isLoggedIn)! ? "You are logged in to Drive" : "You are not logged in to Drive"
            break
            
            case cellLogInOutIdentifier:
                 cell.textLabel?.textColor = (viewModel?.isLoggedIn)! ? UIColor.red : UIColor.black
                 cell.textLabel?.text = (viewModel?.isLoggedIn)! ? "Log Out From Drive" : "Log In To Drive"
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == cellLogInOutIdentifier
        {
            if (viewModel?.isLoggedIn)!
            {
                viewModel?.logOut()
            }
            else
            {
                viewModel?.loginToDrive()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loginToDrive()
    {
        viewModel?.loginToDrive()
    }
    
    func logOutFromDrive()
    {
        viewModel?.logOut()
    }
}

extension YSSettingsTableViewController : YSSettingsViewModelViewDelegate
{
    func errorDidChange(viewModel: YSSettingsViewModel, error: YSError)
    {
        switch error
        {
        case .couldNotLoginToDrive:
            let warning = MessageView.viewFromNib(layout: .CardView)
            warning.configureTheme(.warning)
            warning.configureDropShadow()
            warning.configureContent(title: "Warning", body: "Couldn't login to Drive")
            warning.button?.setTitle("Try Again", for: UIControlState.normal)
            warning.button?.addTarget(self, action: #selector(YSSettingsTableViewController.loginToDrive), for: UIControlEvents.touchUpInside)
            warning.buttonTapHandler =
                { _ in
                    viewModel.loginToDrive()
                    SwiftMessages.hide(id: warning.id)
            }
            var warningConfig = SwiftMessages.Config()
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            SwiftMessages.show(config: warningConfig, view: warning)
            break
            
        case .couldNotLogOutFromDrive:
            let warning = MessageView.viewFromNib(layout: .CardView)
            warning.configureTheme(.warning)
            warning.configureDropShadow()
            warning.configureContent(title: "Warning", body: "Couldn't log out from Drive")
            warning.button?.setTitle("Try Again", for: UIControlState.normal)
            warning.button?.addTarget(self, action: #selector(YSSettingsTableViewController.logOutFromDrive), for: UIControlEvents.touchUpInside)
            warning.buttonTapHandler =
                { _ in
                    viewModel.loginToDrive()
                    SwiftMessages.hide(id: warning.id)
            }
            var warningConfig = SwiftMessages.Config()
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            SwiftMessages.show(config: warningConfig, view: warning)
            break
            
        default: break
        }
    }
}
