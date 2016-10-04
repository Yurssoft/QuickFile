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
    @IBOutlet var toolbarView: YSToolbarView!
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [editButtonItem, loginButton]
        refreshDisplay()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(!isEditing, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        navigationController?.setToolbarHidden(!editing, animated: true)
        tabBarController?.hideTabBar(animated: false)
        toolbar?.isTranslucent = true
        toolbar?.translatesAutoresizingMaskIntoConstraints = false
        tabBarController?.view.addSubview(toolbar!)
        let views = ["toolbar":toolbar]
        tabBarController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_editingToolbar]|", options:NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        
    }
    
    @IBAction func deleteToolbarButtonTapped(_ sender: UIBarButtonItem)
    {
        viewModel?.removeItems()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIBarButtonItem)
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
