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
    
    var viewModel: YSPlaylistViewModelProtocol?
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
        tableView.delegate = self
        tableView.dataSource = self
        let bundle = Bundle(for: YSDriveFileTableViewCell.self)
        let nib = UINib(nibName: YSDriveFileTableViewCell.nameOfClass, bundle: bundle)
        
        tableView.register(nib, forCellReuseIdentifier: YSDriveFileTableViewCell.nameOfClass)
        setupCoordinator()
    }
    
    func setupCoordinator()
    {
        let playlistCoordinator = YSPlaylistCoordinator.init(playlistViewController: self)
        playlistCoordinator.start()
    }
}

extension YSPlaylistViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (viewModel?.numberOfFiles(in: section))!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return (viewModel?.numberOfFolders)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: YSDriveFileTableViewCell.nameOfClass, for: indexPath) as! YSDriveFileTableViewCell
        let file = viewModel?.file(at: indexPath.row, folderIndex: indexPath.section)
        cell.configureForPlaylist(file)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return YSConstants.kCellHeight
    }
}

extension YSPlaylistViewController : UITableViewDelegate
{
    
}

extension YSPlaylistViewController : YSPlaylistViewModelViewDelegate
{
    func filesDidChange(viewModel: YSPlaylistViewModelProtocol)
    {
        DispatchQueue.main.async
        {
            [weak self] in self?.tableView.reloadData()
        }
    }
    
    func errorDidChange(viewModel: YSPlaylistViewModelProtocol, error: YSErrorProtocol)
    {
        
    }
}
