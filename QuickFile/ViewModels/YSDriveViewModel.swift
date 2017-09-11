//
//  YSDriveViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

class YSDriveViewModel: YSDriveViewModelProtocol
{
    var isLoggedIn: Bool
    {
       return (model?.isLoggedIn)!
    }
    
    var isFilesPresent: Bool
    {
        return !files.isEmpty
    }
    
    var error : YSErrorProtocol = YSError()
    {
        didSet
        {
            if !error.isEmpty()
            {
                viewDelegate?.errorDidChange(viewModel: self, error: error)
            }
        }
    }

    weak var viewDelegate: YSDriveViewModelViewDelegate?
    {
        didSet
        {
            viewDelegate?.metadataDownloadStatusDidChange(viewModel: self)
        }
    }
    
    weak var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate?
    
    fileprivate var files = [YSDriveFileProtocol]()
    {
        didSet
        {
            viewDelegate?.filesDidChange(viewModel: self)
        }
    }
    
    var isDownloadingMetadata : Bool = false
    {
        didSet
        {
            viewDelegate?.metadataDownloadStatusDidChange(viewModel: self)
        }
    }
    
    var model: YSDriveModelProtocol?
    {
        didSet
        {
            refreshFiles { }
        }
    }
    
    var numberOfFiles: Int
    {
        return files.count
    }
    
    var allPagesDownloaded = false
    
    fileprivate var pageTokens = [YSConstants.kFirstPageToken]
    
    func file(at index: Int) -> YSDriveFileProtocol?
    {
        if files.count > index
        {
            return files[index]
        }
        return nil
    }
    
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    {
        return model?.download(for: fileDriveIdentifier)
    }
    
    func useFile(at index: Int)
    {
        if let coordinatorDelegate = coordinatorDelegate, index < files.count
        {
            coordinatorDelegate.driveViewModelDidSelectFile(self, file: files[index])
        }
    }
    
    func loginToDrive()
    {
        coordinatorDelegate?.driveViewModelDidRequestedLogin()
    }
    
    func removeDownloads()
    {
        files.removeAll()
        viewDelegate?.filesDidChange(viewModel: self)
    }
    
    fileprivate func getFiles(_ completion: @escaping FilesCompletionHandler)
    {
        isDownloadingMetadata = true
        model?.getFiles(pageToken: pageTokens.first!, nextPageToken: pageTokens.count > 1 ? pageTokens.last : nil)
        { [unowned self] (files, error, nextPageToken) in
            if let errorDebugInfo = error?.debugInfo, errorDebugInfo.contains("cancelled")
            {
                return
            }
            self.error = error!
            completion(files)
            self.isDownloadingMetadata = false
            guard let token = nextPageToken else
            {
                self.allPagesDownloaded = true
                return
            }
            self.allPagesDownloaded = false
            self.pageTokens.append(token)
        }
    }
    
    func driveViewControllerDidFinish()
    {
        coordinatorDelegate?.driveViewModelDidFinish()
    }
    
    func driveViewControllerDidRequestedSearch()
    {
        coordinatorDelegate?.driveViewControllerDidRequestedSearch()
    }
    
    func download(_ fileDriveIdentifier: String)
    {
        if !isLoggedIn
        {
            showNotLoggedInMessage()
            return
        }
        model?.download(fileDriveIdentifier)
    }
    
    func stopDownloading(_ fileDriveIdentifier: String)
    {
        model?.stopDownload(fileDriveIdentifier)
    }
    
    func index(of file : YSDriveFileProtocol) -> Int
    {
        if let index = files.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier})
        {
            return index
        }
        return 0
    }
    
    func deleteDownloadsFor(_ indexes : Set<IndexPath>)
    {
        for indexPath in indexes
        {
            let file = files[indexPath.row]
            if file.isAudio
            {
                stopDownloading(file.fileDriveIdentifier)
                file.removeLocalFile()
                files[indexPath.row] = file
            }
        }
        coordinatorDelegate?.driveViewControllerDidDeletedFiles()
        viewDelegate?.filesDidChange(viewModel: self)
    }
    
    func downloadFilesFor(_ indexes : Set<IndexPath>)
    {
        for indexPath in indexes
        {
            let file = files[indexPath.row]
            download(file.fileDriveIdentifier)
        }
    }
    
    func refreshFiles(_ completion: @escaping () -> Swift.Void)
    {
        if !isLoggedIn
        {
            completion()
            showNotLoggedInMessage()
            return
        }
        guard !isDownloadingMetadata else
        {
            completion()
            return
        }
        pageTokens = [YSConstants.kFirstPageToken]
        getFiles
        {[unowned self]  files in
            self.files = files
            completion()
        }
    }
    
    func getNextPartOfFiles(_ completion: @escaping () -> Swift.Void)
    {
        if !isLoggedIn
        {
            completion()
            showNotLoggedInMessage()
            return
        }
        guard !isDownloadingMetadata, pageTokens.count > 1 else
        {
            completion()
            return
        }
        getFiles
        {[unowned self]  (files) in
            self.files += files
            completion()
        }
    }
    
    fileprivate func showNotLoggedInMessage()
    {
        let errorMessage = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Warning", message: "Could not get list, please login", buttonTitle: "Login", debugInfo: "")
        error = errorMessage
    }
}

extension YSDriveViewModel : YSUpdatingDelegate
{
    func downloadDidChange(_ download : YSDownloadProtocol,_ error: YSErrorProtocol?)
    {
        if let error = error
        {
            self.viewDelegate?.downloadErrorDidChange(viewModel: self, error: error, download: download)
        }
        let index = self.files.index(where: {$0.fileDriveIdentifier == download.fileDriveIdentifier})
        guard let indexx = index, self.files.count > indexx else { return }
        self.viewDelegate?.reloadFileDownload(at: indexx, viewModel: self)
    }
    
    func filesDidChange()
    {
        self.viewDelegate?.filesDidChange(viewModel: self)
    }
}
