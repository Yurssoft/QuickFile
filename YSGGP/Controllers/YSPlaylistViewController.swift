//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import LNPopupController

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
        tableView.dataSource = self
        tableView.delegate = self
        let cellBundle = Bundle(for: YSDriveFileTableViewCell.self)
        let cellNib = UINib(nibName: YSDriveFileTableViewCell.nameOfClass, bundle: cellBundle)
        
        tableView.register(cellNib, forCellReuseIdentifier: YSDriveFileTableViewCell.nameOfClass)
        
        let headerBundle = Bundle(for: YSHeaderForSection.self)
        let headerNib = UINib(nibName: YSHeaderForSection.nameOfClass, bundle: headerBundle)
        
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: YSHeaderForSection.nameOfClass)
        
        setupCoordinator()
    }
    
    func setupCoordinator()
    {
        let playlistCoordinator = YSPlaylistCoordinator.init(playlistViewController: self, navigationController: navigationController!)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        viewModel?.useFile(at: indexPath.section, file: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: YSHeaderForSection.nameOfClass) as! YSHeaderForSection
        let folder = viewModel?.folder(at: section)
        headerView.configure(title: folder?.fileName)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return YSConstants.kHeaderHeight
    }
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
