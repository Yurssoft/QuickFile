//
//  YSDriveViewModelViewDelegate.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDriveViewModelViewDelegate: class
{
    func filesDidChange(viewModel: YSDriveViewModel)
    func metadataDownloadStatusDidChange(viewModel: YSDriveViewModel)
    func errorDidChange(viewModel: YSDriveViewModel, error: YSErrorProtocol)
    func reloadFile(at index: Int, viewModel: YSDriveViewModel)
}

protocol YSDriveViewModelCoordinatorDelegate: class
{
    func driveViewModelDidSelectFile(_ viewModel: YSDriveViewModel, file: YSDriveFileProtocol)
    func driveViewModelDidRequestedLogin()
    func driveViewModelDidFinish()
}

protocol YSDriveViewModelProtocol
{
    var model: YSDriveModelProtocol? { get set }
    var viewDelegate: YSDriveViewModelViewDelegate? { get set }
    var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate? { get set}
    var numberOfFiles: Int { get }
    var isFilesPresent: Bool { get }
    var isLoggedIn: Bool { get }
    var isDownloadingMetadata: Bool { get }
    var error : YSErrorProtocol { get }
    
    func file(at index: Int) -> YSDriveFileProtocol?
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
    func useFile(at index: Int)
    func loginToDrive()
    func removeDownloads()
    func getFiles(completion: @escaping CompletionHandler)
    func driveViewControllerDidFinish()
    func download(_ file : YSDriveFileProtocol)
}
