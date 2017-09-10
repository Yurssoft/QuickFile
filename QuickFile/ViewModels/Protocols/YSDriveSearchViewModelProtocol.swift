//
//  YSDriveSearchViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 2/20/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

enum YSSearchSectionType : String
{
    case all = "All"
    case files = "Files"
    case folders = "Folders"
}

enum YSSearchSection : Int
{
    case localFiles
    case globalFiles
}

protocol YSDriveSearchViewModelViewDelegate: class
{
    func filesDidChange(viewModel: YSDriveSearchViewModelProtocol)
    func metadataDownloadStatusDidChange(viewModel: YSDriveSearchViewModelProtocol)
    func errorDidChange(viewModel: YSDriveSearchViewModelProtocol, error: YSErrorProtocol)
    func downloadErrorDidChange(viewModel: YSDriveSearchViewModelProtocol, error: YSErrorProtocol, fileDriveIdentifier : String)
    func downloadErrorDidChange(viewModel: YSDriveSearchViewModelProtocol, error: YSErrorProtocol, download : YSDownloadProtocol)
    func reloadFileDownload(at index: Int, viewModel: YSDriveSearchViewModelProtocol)
}

protocol YSDriveSearchViewModelCoordinatorDelegate: class
{
    func searchViewModelDidSelectFile(_ viewModel: YSDriveSearchViewModelProtocol, file: YSDriveFileProtocol)
    func searchViewModelDidFinish()
    func subscribeToDownloadingProgress()
}

protocol YSDriveSearchViewModelProtocol
{
    var model: YSDriveSearchModelProtocol? { get set }
    weak var viewDelegate: YSDriveSearchViewModelViewDelegate? { get set }
    weak var coordinatorDelegate: YSDriveSearchViewModelCoordinatorDelegate? { get set }
    var numberOfLocalFiles: Int { get }
    var numberOfGlobalFiles: Int { get }
    var isDownloadingMetadata: Bool { get }
    var error : YSErrorProtocol { get }
    var searchTerm : String { get set }
    var sectionType: YSSearchSectionType { get set }
    var allPagesDownloaded : Bool { get }
    
    func subscribeToDownloadingProgress()
    func updateLocalResults()
    func updateGlobalResults()
    func file(at indexPath: IndexPath) -> YSDriveFileProtocol?
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    func useFile(at indexPath: IndexPath)
    func getNextPartOfFiles(_ completion: @escaping () -> Swift.Void)
    func searchViewControllerDidFinish()
    func download(_ fileDriveIdentifier : String)
    func stopDownloading(_ fileDriveIdentifier: String)
    func indexPath(of file : YSDriveFileProtocol) -> IndexPath
}
