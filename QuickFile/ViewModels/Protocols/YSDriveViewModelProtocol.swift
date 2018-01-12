//
//  YSDriveViewModelViewDelegate.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDriveViewModelViewDelegate: class {
    func filesDidChange(viewModel: YSDriveViewModelProtocol)
    func metadataDownloadStatusDidChange(viewModel: YSDriveViewModelProtocol)
    func errorDidChange(viewModel: YSDriveViewModelProtocol, error: YSErrorProtocol)
    func downloadErrorDidChange(viewModel: YSDriveViewModelProtocol, error: YSErrorProtocol, download: YSDownloadProtocol)
    func downloadErrorDidChange(viewModel: YSDriveViewModelProtocol, error: YSErrorProtocol, fileDriveIdentifier: String)
    func reloadFile(at index: Int, viewModel: YSDriveViewModelProtocol)
    func reloadFileDownload(at index: Int, download: YSDownloadProtocol, viewModel: YSDriveViewModelProtocol)
}

protocol YSDriveViewModelCoordinatorDelegate: class {
    func driveViewModelDidSelectFile(_ viewModel: YSDriveViewModelProtocol, file: YSDriveFileProtocol)
    func driveViewModelDidRequestedLogin()
    func driveViewModelDidFinish()
    func driveViewControllerDidRequestedSearch()
    func driveViewControllerDidDeletedFiles()
}

protocol YSDriveViewModelProtocol {
    var model: YSDriveModelProtocol? { get set }
    weak var viewDelegate: YSDriveViewModelViewDelegate? { get set }
    weak var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate? { get set}
    var numberOfFiles: Int { get }
    var isFilesPresent: Bool { get }
    var isLoggedIn: Bool { get }
    var isDownloadingMetadata: Bool { get }
    var error: YSErrorProtocol { get }
    var allPagesDownloaded: Bool { get }

    func file(at index: Int) -> YSDriveFileProtocol?
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    func useFile(at index: Int)
    func loginToDrive()
    func removeDownloads()
    func driveViewControllerDidFinish()
    func driveViewControllerDidRequestedSearch()
    func download(_ fileDriveIdentifier: String)
    func stopDownloading(_ fileDriveIdentifier: String)
    func index(of file: YSDriveFileProtocol) -> Int
    func deleteDownloadsFor(_ indexes: Set<IndexPath>)
    func downloadFilesFor(_ indexes: Set<IndexPath>)
    func refreshFiles(_ completion: @escaping () -> Swift.Void)
    func getNextPartOfFiles(_ completion: @escaping () -> Swift.Void)
}
