//
//  YSDriveTopViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/4/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveTopViewController: UIViewController
{
    @IBOutlet internal weak var editButton: UIBarButtonItem!
    @IBOutlet internal weak var containerView: UIView!
    @IBOutlet internal weak var toolbarViewBottomConstraint : NSLayoutConstraint?
    @IBOutlet internal weak var toolbarView: YSToolbarView?
    internal var loginNavigationButton : UIBarButtonItem?
    internal var driveVC : YSDriveViewController?
    
    internal let toolbarViewBottomConstraintVisibleConstant = 0 as CGFloat
    internal let toolbarViewBottomConstraintHiddenConstant = -100 as CGFloat
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCoordinator()
        
        driveVC?.toolbarView = toolbarView
        driveVC?.containingViewControllerViewDidLoad()
        loginNavigationButton = UIBarButtonItem(title: "Login", style:UIBarButtonItemStyle.plain, target: self, action: #selector(YSDriveTopViewController.loginButtonTapped(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !(driveVC?.viewModel?.isLoggedIn)!
        {
            navigationItem.setLeftBarButton(loginNavigationButton, animated: true)
        }
    }
    
    func setupCoordinator()
    {
        let driveCoordinator = YSDriveCoordinator(driveViewController: driveVC!, navigationController: navigationController!)
        driveCoordinator.start()
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
