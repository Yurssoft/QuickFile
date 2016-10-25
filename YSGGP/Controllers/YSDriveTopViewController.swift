//
//  YSDriveTopViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/4/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

typealias DriveViewControllerDidLoadedHandler = () -> Swift.Void

protocol YSDriveViewControllerDidFinishedLoading: class
{
    func driveViewControllerDidLoaded(driveVC: YSDriveViewController, navigationController: UINavigationController)
}

class YSDriveTopViewController: UIViewController
{
    @IBOutlet fileprivate weak var editButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var toolbarViewBottomConstraint : NSLayoutConstraint?
    @IBOutlet fileprivate weak var toolbarView: YSToolbarView?
    fileprivate var loginNavigationButton : UIBarButtonItem?
    var driveVC : YSDriveViewController?
    
    var driveVCReadyDelegate : YSDriveViewControllerDidFinishedLoading?
    var driveViewControllerDidLoadedHandler : DriveViewControllerDidLoadedHandler?
    
    fileprivate let toolbarViewBottomConstraintVisibleConstant = 0 as CGFloat
    fileprivate let toolbarViewBottomConstraintHiddenConstant = -100 as CGFloat
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        driveVC?.toolbarView = toolbarView
        driveVC?.containingViewControllerViewDidLoad()
        loginNavigationButton = UIBarButtonItem(title: "Login", style:UIBarButtonItemStyle.plain, target: self, action: #selector(YSDriveTopViewController.loginButtonTapped(_:)))
        driveVCReadyDelegate?.driveViewControllerDidLoaded(driveVC: driveVC!, navigationController: navigationController!)
        if let handler = driveViewControllerDidLoadedHandler
        {
            handler()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !(driveVC?.viewModel?.isLoggedIn)!
        {
            navigationItem.setLeftBarButton(loginNavigationButton, animated: true)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem)
    {
        driveVC?.setEditing(!(driveVC?.isEditing)!, animated: true)
        toolbarView?.isHidden = !(driveVC?.isEditing)!
        navigationItem.leftBarButtonItem = (driveVC?.isEditing)! ? nil : loginNavigationButton
        sender.title = (driveVC?.isEditing)! ? "Done" : "Edit"
        tabBarController?.setTabBarVisible(isVisible: !(driveVC?.isEditing)!, animated: true, completion:nil)
    }
    
    func loginButtonTapped(_ sender: AnyObject)
    {
        driveVC?.loginButtonTapped(sender as! UIBarButtonItem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let segueIdentifier = YSConstants.kDriveEmbededSegue
        
        if segue.identifier == segueIdentifier
        {
            driveVC = segue.destination as? YSDriveViewController
        }
    }
}
