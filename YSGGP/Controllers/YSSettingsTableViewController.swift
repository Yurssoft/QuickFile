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
                logOutFromDrive()
            }
            else
            {
                loginToDrive()
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
        let alertController = UIAlertController(title: "Log Out?", message: "If you log out you won't be able to download songs.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Log Out", style: .destructive)
        { (action) in
            self.viewModel?.logOut()
        }
        alertController.addAction(destroyAction)
        
        present(alertController, animated: true)
    }
}

extension YSSettingsTableViewController : YSSettingsViewModelViewDelegate
{
    func errorDidChange(viewModel: YSSettingsViewModel, error: YSError)
    {
        switch error.errorType
        {
        case .couldNotLoginToDrive:
            let warning = MessageView.viewFromNib(layout: .CardView)
            warning.configureTheme(.warning)
            warning.configureDropShadow()
            warning.configureContent(title: "Warning", body: error.message)
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
            
        case .cancelledLoginToDrive:
            let warning = MessageView.viewFromNib(layout: .CardView)
            warning.configureTheme(.warning)
            warning.configureDropShadow()
            warning.configureContent(title: "Warning", body: error.message)
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
            warning.configureContent(title: "Warning", body: error.message)
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
