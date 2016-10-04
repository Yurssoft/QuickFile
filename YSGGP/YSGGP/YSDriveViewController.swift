//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveViewController: UITableViewController
{
    weak var toolbarView: YSToolbarView!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        toolbarView.isHidden = !editing
        tabBarController?.hideTabBar(animated: false)
    }
    
    func deleteToolbarButtonTapped(_ sender: UIBarButtonItem)
    {
        viewModel?.removeItems()
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
}
