//
//  YSSettingsViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/21/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSSettingsTableViewController: UITableViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
