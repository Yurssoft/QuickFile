//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftMessages

class YSDriveViewController: UITableViewController
{
    weak var toolbarView: YSToolbarView!
    
    var viewModel: YSDriveViewModel?
    {
        willSet
        {
            viewModel?.viewDelegate = nil
        }
        didSet
        {
            viewModel?.viewDelegate = self
            refreshDisplay()
        }
    }
    
    func containingViewControllerViewDidLoad()
    {
        refreshDisplay()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func deleteToolbarButtonTapped(_ sender: UIBarButtonItem)
    {
        viewModel?.removeDownloads()
    }
    
    func loginButtonTapped(_ sender: UIBarButtonItem)
    {
        viewModel?.loginToDrive()
    }
    
    func refreshDisplay()
    {
        if (viewIfLoaded != nil)
        {
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let viewModel = viewModel
        {
            return viewModel.numberOfItems
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: YSDriveItemTableViewCell.nameOfClass, for: indexPath) as! YSDriveItemTableViewCell
        cell.item = viewModel?.itemAtIndex((indexPath as NSIndexPath).row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        viewModel?.useItemAtIndex((indexPath as NSIndexPath).row)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .insert
    }
    
    func fetchItemsAgain()
    {
        
    }
}

extension YSDriveViewController: YSDriveViewModelViewDelegate
{
    func itemsDidChange(viewModel: YSDriveViewModel)
    {
        DispatchQueue.main.async
        {
            [weak self] in self?.tableView.reloadData()
        }
    }
    
    func errorDidChange(viewModel: YSDriveViewModel, error: YSError)
    {
        switch error
        {
        case .couldNotGetFileList:
            let warning = MessageView.viewFromNib(layout: .CardView)
            warning.configureTheme(.warning)
            warning.configureDropShadow()
            warning.configureContent(title: "Warning", body: "Couldn't get list")
            warning.button?.setTitle("Try Again", for: UIControlState.normal)
            warning.button?.addTarget(self, action: #selector(YSDriveViewController.fetchItemsAgain), for: UIControlEvents.touchUpInside)
            warning.buttonTapHandler = { _ in SwiftMessages.hide(id: warning.id) }
            var warningConfig = SwiftMessages.Config()
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            SwiftMessages.show(config: warningConfig, view: warning)
            break
            
        case .couldNotLoginToDrive:
            let warning = MessageView.viewFromNib(layout: .CardView)
            warning.configureTheme(.warning)
            warning.configureDropShadow()
            warning.configureContent(title: "Warning", body: "You are not logged in to Drive")
            warning.button?.setTitle("Login", for: UIControlState.normal)
            warning.button?.addTarget(self, action: #selector(YSDriveViewController.loginButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            warning.buttonTapHandler = { _ in SwiftMessages.hide(id: warning.id) }
            var warningConfig = SwiftMessages.Config()
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            SwiftMessages.show(config: warningConfig, view: warning)
            break
            
        default: break
        }
    }
}
