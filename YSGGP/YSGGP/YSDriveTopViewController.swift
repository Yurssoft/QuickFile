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
    @IBOutlet weak var containerView: UIView!
    var driveVC : YSDriveViewController?
    
    @IBOutlet weak var toolbarView: YSToolbarView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if driveVC == nil
        {
            print("driveVC == nil")
        }
        let driveCoordinator = YSDriveCoordinator(driveViewController: driveVC!, navigationController: navigationController!)
        driveCoordinator.start()
        driveVC?.toolbarView = toolbarView
        driveVC?.containingViewControllerViewDidLoad()
    }
    
    @IBAction func editButtonTapped(_ sender: AnyObject)
    {
        driveVC?.setEditing(!(driveVC?.isEditing)!, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: AnyObject)
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
