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
import Firebase

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
    
    fileprivate var signInButton: GIDSignInButton?
    
    fileprivate let cellLogInOutIdentifier = "logInOutCell"
    fileprivate let cellLogInOutInfoIdentifier = "loggedInOutInfoCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        signInButton = GIDSignInButton.init()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
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
        GIDSignIn.sharedInstance().signInSilently()
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
        signIn.scopes = YSConstants.kDriveScopes
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        dismiss(animated: true)
    }
}

extension YSSettingsTableViewController : GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if let error = error
        {
            let errorString = error.localizedDescription
            
            //could not sign in silently, call explicit sign in
            if errorString.contains("error -4") || errorString.contains("couldn’t be completed") || errorString.contains("-4")
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    self.signInButton?.sendActions(for: UIControlEvents.touchUpInside)
                }
                return
            }
            if errorString.contains("Code=-5") || errorString.contains("canceled") || errorString.contains("-5")
            {
                let messageCancelled = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Warning", message: "Cancelled login to Drive", buttonTitle: "Login", debugInfo: error.localizedDescription)
                errorDidChange(viewModel: viewModel!, error: messageCancelled)
                return
            }
            let messagecouldNotLogOut = YSError(errorType: YSErrorType.couldNotLogOutFromDrive, messageType: Theme.warning, title: "Warning", message: "Could not log out from drive", buttonTitle: "Try again", debugInfo: error.localizedDescription)
            let messageCouldNotLogin = YSError(errorType: YSErrorType.couldNotLoginToDrive, messageType: Theme.warning, title: "Warning", message: "Could not login to Drive", buttonTitle: "Try again", debugInfo: error.localizedDescription)
            errorDidChange(viewModel: viewModel!, error: signIn.hasAuthInKeychain() ? messagecouldNotLogOut : messageCouldNotLogin)
            return
        }
        let authentication = user.authentication
        YSCredentialManager.shared.setTokens(refreshToken: (authentication?.refreshToken)!,
                                            accessToken: (authentication?.accessToken)!,
                                            availableTo: (authentication?.accessTokenExpirationDate)!)
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            
        }
        
        let messageLoggedIn = YSError(errorType: YSErrorType.loggedInToToDrive, messageType: Theme.success, title: "Success", message: "Logged in to Drive", buttonTitle: "GOT IT", debugInfo: "")
        errorDidChange(viewModel: viewModel!, error: messageLoggedIn)
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
        case .cancelledLoginToDrive, .couldNotLoginToDrive, .notLoggedInToDrive:
            message.buttonTapHandler =
                { _ in
                SwiftMessages.hide(id: message.id)
                self.loginToDrive()
            }
            break
            
        case .couldNotLogOutFromDrive:
            message.buttonTapHandler =
            { _ in
                SwiftMessages.hide(id: message.id)
                self.logOutFromDrive()
            }
            break
            
        default: break
        }
        
        var messageConfig = SwiftMessages.Config()
        messageConfig.duration = .forever
        messageConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: messageConfig, view: message)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.tableView.reloadData()
        }
    }
}
