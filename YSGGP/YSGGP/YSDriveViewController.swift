//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveViewController: UIViewController
{
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
        refreshDisplay();
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
    
    
    func refreshDisplay()
    {
        //        if let viewModel = viewModel , isViewLoaded {
        //            title = viewModel.title
        //        } else {
        //            title = ""
        //        }
        self.tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let viewModel = viewModel {
            return viewModel.numberOfItems
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! YSDriveItemTableViewCell
        cell.item = viewModel?.itemAtIndex((indexPath as NSIndexPath).row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        viewModel?.useItemAtIndex((indexPath as NSIndexPath).row)
    }
    
}

extension YSDriveViewController: YSDriveViewModelViewDelegate
{
    func itemsDidChange(viewModel: YSDriveViewModel)
    {
        tableView.reloadData()
    }
}
