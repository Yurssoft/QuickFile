//
//  YSSettingsTopViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/18/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftyBeaver

class YSSettingsTopViewController: UIViewController
{
    var settingsVC: YSSettingsTableViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCoordinator()
        let log = SwiftyBeaver.self
        log.info("")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let log = SwiftyBeaver.self
        log.info("")
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        let log = SwiftyBeaver.self
        log.info("")
    }
    
    func setupCoordinator()
    {
        YSAppDelegate.appDelegate().settingsCoordinator.start(settingsViewController: settingsVC!)
    }
    
    @IBAction func refreshSettings(_ sender: UIBarButtonItem)
    {
        settingsVC.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let segueIdentifier = YSConstants.kSettingsEmbededSegue
        
        if segue.identifier == segueIdentifier
        {
            settingsVC = segue.destination as? YSSettingsTableViewController
        }
    }
}
