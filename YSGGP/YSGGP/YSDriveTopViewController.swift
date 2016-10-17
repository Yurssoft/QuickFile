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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toolbarViewBottomConstraint : NSLayoutConstraint?
    @IBOutlet weak var toolbarView: YSToolbarView?
    var loginNavigationButton : UIBarButtonItem?
    var driveVC : YSDriveViewController?
    
    let toolbarViewBottomConstraintVisibleConstant = 0 as CGFloat
    let toolbarViewBottomConstraintHiddenConstant = -100 as CGFloat
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let driveCoordinator = YSDriveCoordinator(driveViewController: driveVC!, navigationController: navigationController!)
        driveCoordinator.start()
        
        
        
        driveVC?.toolbarView = toolbarView
        driveVC?.containingViewControllerViewDidLoad()
        loginNavigationButton = UIBarButtonItem(title: "Login", style:UIBarButtonItemStyle.plain, target: self, action: #selector(YSDriveTopViewController.loginButtonTapped(_:)))
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
