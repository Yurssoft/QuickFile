//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSPlaylistViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: YSDriveViewModelProtocol?
        {
        willSet
        {
            viewModel?.viewDelegate = nil
        }
        didSet
        {
            viewModel?.viewDelegate = self
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension YSPlaylistViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell.init()
    }
}
