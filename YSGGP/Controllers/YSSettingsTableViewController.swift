//
//  YSSettingsViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/21/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftMessages
import GoogleSignIn

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
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var loginOutLabel: UILabel!
    
    let cellLogInOutIdentifier = "logInOutCell"
    let cellLogInOutInfoIdentifier = "loggedInOutInfoCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        switch cell.reuseIdentifier!
        {
            case cellLogInOutInfoIdentifier:
                cell.textLabel?.text = (viewModel?.isLoggedIn)! ? "You are logged in to Drive" : "You are not logged in to Drive"
            break
            
            case cellLogInOutIdentifier:
                 loginOutLabel.textColor = (viewModel?.isLoggedIn)! ? UIColor.red : UIColor.black
                 loginOutLabel.text = (viewModel?.isLoggedIn)! ? "Log Out From Drive" : "Log In To Drive"
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
        }
        tableView.deselectRow(at: indexPath, animated: true)
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

extension YSSettingsTableViewController : GIDSignInUIDelegate
{
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!)
    {
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        dismiss(animated: true, completion: nil)
    }
}

extension YSSettingsTableViewController : YSSettingsViewModelViewDelegate
{
    func errorDidChange(viewModel: YSSettingsViewModel, error: YSErrorProtocol)
    {
        let message = MessageView.viewFromNib(layout: .CardView)
        message.configureTheme(error.messageType)
        message.configureDropShadow()
        message.configureContent(title: error.title, body: error.message)
        message.button?.setTitle(error.buttonTitle, for: UIControlState.normal)
        switch error.errorType
        {
        case .loggedInToToDrive:
            message.buttonTapHandler =
            { _ in
                SwiftMessages.hide(id: message.id)
            }
            break
        case .cancelledLoginToDrive, .couldNotLoginToDrive:
            message.buttonTapHandler =
            { _ in
                //call login
                SwiftMessages.hide(id: message.id)
            }
            break
            
        case .couldNotLogOutFromDrive:
            message.buttonTapHandler =
            { _ in
                self.logOutFromDrive()
                SwiftMessages.hide(id: message.id)
            }
            break
            
        default: break
        }
        
        var warningConfig = SwiftMessages.Config()
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: warningConfig, view: message)
        tableView.reloadData()
    }
}
