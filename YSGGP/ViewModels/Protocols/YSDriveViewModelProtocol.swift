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
}

protocol YSDriveViewModelCoordinatorDelegate: class
{
    func driveViewModelDidSelectFile(_ viewModel: YSDriveViewModel, file: YSDriveFileProtocol)
    func driveViewModelDidRequestedLogin()
    func driveViewModelDidFinish()
}

protocol YSDriveViewModelProtocol
{
    var model: YSDriveModel? { get set }
    var viewDelegate: YSDriveViewModelViewDelegate? { get set }
    var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate? { get set}
    var numberOfFiles: Int { get }
    var isFilesPresent: Bool { get }
    var isLoggedIn: Bool { get }
    var isDownloadingMetadata: Bool { get }
    var error : YSErrorProtocol { get }
    
    func fileAtIndex(_ index: Int) -> YSDriveFileProtocol?
    func useFileAtIndex(_ index: Int)
    func loginToDrive()
    func removeDownloads()
    func getFiles(completion: @escaping CompletionHandler)
    func driveViewControllerDidFinish()
}
