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
            return viewModel.numberOfFiles
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: YSDriveFileTableViewCell.nameOfClass, for: indexPath) as! YSDriveFileTableViewCell
        cell.file = viewModel?.fileAtIndex((indexPath as NSIndexPath).row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        viewModel?.useFileAtIndex((indexPath as NSIndexPath).row)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .insert
    }
    
    func getList()
    {
        
    }
    
    func getRootFolder()
    {
        
    }
}

extension YSDriveViewController: YSDriveViewModelViewDelegate
{
    func filesDidChange(viewModel: YSDriveViewModel)
    {
        DispatchQueue.main.async
        {
            [weak self] in self?.tableView.reloadData()
        }
    }
    
    func errorDidChange(viewModel: YSDriveViewModel, error: YSError)
    {
        let message = MessageView.viewFromNib(layout: .CardView)
        message.configureTheme(error.messageType)
        message.configureDropShadow()
        message.configureContent(title: error.title, body: error.message)
        message.button?.setTitle(error.buttonTitle, for: UIControlState.normal)
        switch error.errorType
        {
        case .cancelledLoginToDrive, .couldNotLoginToDrive, .notLoggedInToDrive:
            message.buttonTapHandler =
            { _ in
                self.loginButtonTapped(UIBarButtonItem())
                SwiftMessages.hide(id: message.id)
            }
            break
            
        case .loggedInToToDrive:
            message.buttonTapHandler =
            { _ in
                SwiftMessages.hide(id: message.id)
            }
            break
            
        case .couldNotGetFileList:
            message.buttonTapHandler =
            { _ in
                self.getList()
                SwiftMessages.hide(id: message.id)
            }
            break
        case .couldNotGetRootFolder:
            message.buttonTapHandler =
            { _ in
                self.getRootFolder()
                SwiftMessages.hide(id: message.id)
            }
            break
            
        default: break
        }
        var warningConfig = SwiftMessages.Config()
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: warningConfig, view: message)
    }
}
