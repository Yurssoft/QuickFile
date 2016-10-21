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
    internal var isLoggedIn: Bool
    {
       return (model?.isLoggedIn)!
    }
    
    internal var isFilesPresent: Bool
    {
        return files != nil && !(files?.isEmpty)!
    }
    
    internal var error : YSError = YSError()
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
    
    var model: YSDriveModel?
    {
        didSet
        {
            files = nil
            
            model?.getFiles()
            { (files, error) in
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
            coordinatorDelegate.driveViewModelDidSelectData(self, file: files[index])
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
}
