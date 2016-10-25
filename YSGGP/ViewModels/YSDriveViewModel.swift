//
//  YSDriveViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSDriveViewModel: YSDriveViewModelProtocol
{
    var isLoggedIn: Bool
    {
       return (model?.isLoggedIn)!
    }
    
    var isFilesPresent: Bool
    {
        return files != nil && !(files?.isEmpty)!
    }
    
    var error : YSError = YSError()
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
    var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate?
    
    fileprivate var files: [YSDriveFile]?
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
    
    var model: YSDriveModel?
    {
        didSet
        {
            files = nil
            isDownloadingMetadata = true
            model?.getFiles()
            { (files, error) in
                self.isDownloadingMetadata = false
                self.files = files
                self.error = error!
            }
        }
    }
    
    var numberOfFiles: Int
    {
        if let files = files
        {
            return files.count
        }
        return 0
    }
    
    func fileAtIndex(_ index: Int) -> YSDriveFile?
    {
        if let files = files , files.count > index
        {
            return files[index]
        }
        return nil
    }
    
    func useFileAtIndex(_ index: Int)
    {
        if let files = files, let coordinatorDelegate = coordinatorDelegate, index < files.count
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
        files?.removeAll()
        viewDelegate?.filesDidChange(viewModel: self)
    }
    
    func getFiles(completion: @escaping CompletionHandler)
    {
        isDownloadingMetadata = true
        model?.getFiles()
            { (files, error) in
            self.isDownloadingMetadata = false
            self.files = files
            self.error = error!
            completion(error)
        }
    }
}
