//
//  YSDriveViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/20/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class YSPlaylistViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var tableView: UITableView!

    var viewModel: YSPlaylistViewModelProtocol? {
        willSet {
            viewModel?.viewDelegate = nil
        }
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    override func viewDidLoad() {
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
        configurePullToRefresh()
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        viewModel?.viewIsLoadedAndReadyToDisplay {
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadData()
        }
    }
    func setupCoordinator() {
        YSAppDelegate.appDelegate().playlistCoordinator.start(playlistViewController: self)
    }

    func configurePullToRefresh() {
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] () -> Void in
            logPlaylistSubdomain(.Controller, .Info, "Requested refresh")
            self?.getFiles()
        })
    }

    func getFiles() {
        viewModel?.getFiles(completion: { [weak self] _ in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.reloadData()
        })
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let promptText = "There are no file yet"
        let attributes = [NSAttributedStringKey.foregroundColor: YSConstants.kDefaultBlueColor, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
        let attributedString = NSAttributedString.init(string: promptText, attributes: attributes)
        return attributedString
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let promptText = "Reload"
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0)]
        let attributedString = NSAttributedString.init(string: promptText, attributes: attributes)
        return attributedString
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "music")
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        getFiles()
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension YSPlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.numberOfFiles(in: section))!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return (viewModel?.numberOfFolders)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YSDriveFileTableViewCell.nameOfClass, for: indexPath)
        if let cell = cell as? YSDriveFileTableViewCell {
            let file = viewModel?.file(at: indexPath.row, folderIndex: indexPath.section)
            cell.configureForPlaylist(file)
        }
        return cell
    }

    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return YSConstants.kCellHeight
    }
}

extension YSPlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        logPlaylistSubdomain(.Controller, .Info, "")
        viewModel?.useFile(at: indexPath.section, file: indexPath.row)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: YSHeaderForSection.nameOfClass)
        if let headerView = headerView as? YSHeaderForSection {
            let folder = viewModel?.folder(at: section)
            headerView.configure(title: folder?.name)
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel?.folder(at: section) == nil ? 0 : YSConstants.kHeaderHeight
    }
}

extension YSPlaylistViewController: YSPlaylistViewModelViewDelegate {
    func fileDidChange(viewModel: YSPlaylistViewModelProtocol) {
        logPlaylistSubdomain(.Controller, .Info, "")
            DispatchQueue.main.async {
                guard self.isViewLoaded, (self.view.window != nil), let indexPaths = self.tableView.indexPathsForVisibleRows, indexPaths.count > 0 else { return }
                self.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    func filesDidChange(viewModel: YSPlaylistViewModelProtocol) {
        logPlaylistSubdomain(.Controller, .Info, "")
        DispatchQueue.main.async {
            [weak self] in self?.tableView.reloadData()
        }
    }

    func errorDidChange(viewModel: YSPlaylistViewModelProtocol, error: YSErrorProtocol) {

    }
}
