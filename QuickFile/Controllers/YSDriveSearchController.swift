//
//  YSDriveSearchController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 2/16/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import UIKit
import SwiftMessages
import DZNEmptyDataSet

class YSDriveSearchController: UITableViewController {
    var viewModel: YSDriveSearchViewModelProtocol? {
        willSet {
            viewModel?.viewDelegate = nil
        }
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    let searchController = UISearchController(searchResultsController: nil)
    fileprivate var pendingRequestForSearchModel: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = [YSSearchSectionType.all.rawValue, YSSearchSectionType.files.rawValue, YSSearchSectionType.folders.rawValue]
        searchController.searchBar.delegate = self
        searchController.delegate = self

        if #available(iOS 11, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        let bundle = Bundle(for: YSDriveFileTableViewCell.self)
        let nib = UINib(nibName: YSDriveFileTableViewCell.nameOfClass, bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: YSDriveFileTableViewCell.nameOfClass)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)

        let footer = MJRefreshAutoNormalFooter.init { [weak self] () -> Void in
            SwiftMessages.hide(id: YSConstants.kOffineStatusBarMessageID)
            logSearchSubdomain(.Controller, .Info, "Footer requested")
            guard let viewModel = self?.viewModel as? YSDriveSearchViewModel else {
                logSearchSubdomain(.Controller, .Info, "Footer cancelled, no model")
                self?.tableView.mj_footer.endRefreshing()
                return
            }
            viewModel.getNextPartOfFiles { [weak viewModel] in
                logSearchSubdomain(.Controller, .Info, "Footer finished with data")
                guard let viewModel = viewModel, viewModel.allPagesDownloaded else {
                    self?.tableView.mj_footer.endRefreshing()
                    return
                }
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
        footer?.isAutomaticallyHidden = true
        tableView.mj_footer = footer
        viewModel?.viewIsLoadedAndReadyToDisplay {
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.subscribeToDownloadingProgress()
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
        pendingRequestForSearchModel?.cancel()
        logSearchSubdomain(.Controller, .Info, "")
        viewModel?.searchViewControllerDidFinish()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = viewModel else { return 0 }
        if viewModel.numberOfLocalFiles == 0 && viewModel.numberOfGlobalFiles == 0 {
            return 0
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        switch YSSearchSection(rawValue: section)! {
        case .localFiles:
            return viewModel.numberOfLocalFiles
        case .globalFiles:
            return viewModel.numberOfGlobalFiles
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return YSConstants.kCellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YSDriveFileTableViewCell.nameOfClass, for: indexPath)
        if let cell = cell as? YSDriveFileTableViewCell {
            let file = viewModel?.file(at: indexPath)
            let download = viewModel?.download(for: file?.id ?? "")
            cell.configureForDrive(file, self, download)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == YSSearchSection.localFiles.rawValue ? "Local results" : "Global results"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logSearchSubdomain(.Controller, .Info, "Row: \(indexPath.row)")
        viewModel?.useFile(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension YSDriveSearchController: YSDriveFileTableViewCellDelegate {
    func downloadButtonPressed(_ id: String) {
        logSearchSubdomain(.Controller, .Info, "File id: " + id)
        viewModel?.download(id)
    }

    func stopDownloadButtonPressed(_ id: String) {
        logSearchSubdomain(.Controller, .Info, "File id: " + id)
        viewModel?.stopDownloading(id)
    }
}

extension YSDriveSearchController: YSDriveSearchViewModelViewDelegate {
    func filesDidChange(viewModel: YSDriveSearchViewModelProtocol) {
        logSearchSubdomain(.Controller, .Info, "")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func metadataDownloadStatusDidChange(viewModel: YSDriveSearchViewModelProtocol) {
        logSearchSubdomain(.Controller, .Info, "")
        DispatchQueue.main.async {
            if !viewModel.isDownloadingMetadata && !viewModel.allPagesDownloaded {
                self.tableView.mj_footer.endRefreshing()
            }
        }
    }

    func errorDidChange(viewModel: YSDriveSearchViewModelProtocol, error: YSErrorProtocol) {
        logSearchSubdomain(.Controller, .Info, "Error: message: " + error.message + " debug message" + error.debugInfo)
        if error.isNoInternetError() {
            SwiftMessages.showNoInternetError(error)
            return
        }
        let message = SwiftMessages.createMessage(error)
        switch error.errorType {
        case .couldNotGetFileList:
            message.buttonTapHandler = { _ in
                viewModel.updateGlobalResults()
            }
        default:
            break
        }
        SwiftMessages.showDefaultMessage(message, isMessageErrorMessage: error.messageType == .error)
    }

    func downloadErrorDidChange(viewModel: YSDriveSearchViewModelProtocol, error: YSErrorProtocol, id: String) {
        logSearchSubdomain(.Controller, .Info, "File id: " + id + " Error: message: " + error.message + " debug message" + error.debugInfo)
        let message = SwiftMessages.createMessage(error)
        switch error.errorType {
        case .couldNotDownloadFile:
            message.buttonTapHandler = { _ in
                self.downloadButtonPressed(id)
                SwiftMessages.hide()
            }
        default: break
        }
        SwiftMessages.showDefaultMessage(message, isMessageErrorMessage: error.messageType == .error)
    }

    func downloadErrorDidChange(viewModel: YSDriveSearchViewModelProtocol, error: YSErrorProtocol, download: YSDownloadProtocol) {
        downloadErrorDidChange(viewModel: viewModel, error: error, id: download.id)
    }

    func reloadFileDownload(at index: Int, download: YSDownloadProtocol, viewModel: YSDriveSearchViewModelProtocol) {
        logSearchSubdomain(.Controller, .Info, "Index: \(index)")
        DispatchQueue.main.async {
            let indexPath = IndexPath.init(row: index, section: 0)
            switch download.downloadStatus {
            case .downloaded:
                self.tableView.reloadRows(at: [indexPath], with: .none)
            default:
                if let cell = self.tableView.cellForRow(at: indexPath) as? YSDriveFileTableViewCell  {
                    cell.updateDownloadButton(download: download)
                } else {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
}

extension YSDriveSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestForSearchModel?.cancel()
        guard let viewModel1 = viewModel as? YSDriveSearchViewModel, let searchText = searchController.searchBar.text, searchText.count > 1 else { return }
        viewModel1.searchTerm = searchText
        logSearchSubdomain(.Controller, .Info, "Search text: " + searchText)
        viewModel1.updateLocalResults()
        // Wrap our request to viewModel in a work item
        let requestWorkItem = DispatchWorkItem { [weak viewModel1] in
            guard let viewModel2 = viewModel1 else { return }
            DispatchQueue.main.async {
                SwiftMessages.hide(id: YSConstants.kOffineStatusBarMessageID)
            }
            viewModel2.updateGlobalResults()
        }
        pendingRequestForSearchModel = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750), execute: requestWorkItem)
    }
}

extension YSDriveSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        pendingRequestForSearchModel?.cancel()
        let section = YSSearchSectionType(rawValue: searchBar.scopeButtonTitles![selectedScope])
        guard let sectionType = section, let viewModel1 = viewModel as? YSDriveSearchViewModel else { return }
        logSearchSubdomain(.Controller, .Info, "Section type: \(sectionType)")
        viewModel1.sectionType = sectionType
        viewModel1.updateLocalResults()
        // Wrap our request to viewModel in a work item
        let requestWorkItem = DispatchWorkItem { [weak viewModel1] in
            guard let viewModel2 = viewModel1 else { return }
            DispatchQueue.main.async {
                SwiftMessages.hide(id: YSConstants.kOffineStatusBarMessageID)
            }
            viewModel2.updateGlobalResults()
        }
        pendingRequestForSearchModel = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750), execute: requestWorkItem)
    }
}

extension YSDriveSearchController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let promptText = "Nothing found"
        let attributes = [NSAttributedStringKey.foregroundColor: YSConstants.kDefaultBlueColor, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
        let attributedString = NSAttributedString.init(string: promptText, attributes: attributes)
        return attributedString
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage {
        let image = #imageLiteral(resourceName: "empty_search").resize(scaleFactor: 0.5)
        return image
    }
}

extension YSDriveSearchController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension YSDriveSearchController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        if var viewModel = viewModel {
            pendingRequestForSearchModel?.cancel()
            viewModel.searchTerm = ""
            viewModel.updateLocalResults()
            viewModel.updateGlobalResults()
        }
    }
}
