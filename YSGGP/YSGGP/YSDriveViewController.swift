//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
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
        tableView.allowsMultipleSelectionDuringEditing = true
        refreshDisplay()
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        if editing
        {
            toolbar?.isHidden = false
            view?.bringSubview(toFront: toolbar)
            tableView.bringSubview(toFront: toolbar)
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let viewModel = viewModel
        {
            return viewModel.numberOfItems
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: YSDriveItemTableViewCell.nameOfClass, for: indexPath) as! YSDriveItemTableViewCell
        cell.item = viewModel?.itemAtIndex((indexPath as NSIndexPath).row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        viewModel?.useItemAtIndex((indexPath as NSIndexPath).row)
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
