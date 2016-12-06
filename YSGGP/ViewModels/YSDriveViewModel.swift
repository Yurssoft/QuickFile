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
        return files != nil && !(files?.isEmpty)!
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
    var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate?
    
    fileprivate var files: [YSDriveFileProtocol]?
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
            files = []
            if !isLoggedIn
            {
                return
            }
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
    
    func file(at index: Int) -> YSDriveFileProtocol?
    {
        if let files = files , files.count > index
        {
            return files[index]
        }
        return nil
    }
    
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
    {
        return model?.download(for: file)
    }
    
    func useFile(at index: Int)
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
    
    func driveViewControllerDidFinish()
    {
        coordinatorDelegate?.driveViewModelDidFinish()
    }
    
    func download(_ file : YSDriveFileProtocol)
    {
        model?.download(file, { (download) in
            let index = self.files?.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier})
            self.viewDelegate?.reloadFileDownload(at: index!, viewModel: self)
        },
        completionHandler: { (download, error) in
            if let error = error
            {
                self.viewDelegate?.downloadErrorDidChange(viewModel: self, error: error, download: download)
            }
            let index = self.files?.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier})
            self.viewDelegate?.reloadFile(at: index!, viewModel: self)
        })
    }
    
    func stopDownloading(_ file: YSDriveFileProtocol)
    {
        model?.stopDownload(file)
    }
    
    func indexOf(_ file : YSDriveFileProtocol) -> Int
    {
        return (files?.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier}))!
    }
    
    func deleteDownloadsFor(_ indexes : [IndexPath])
    {
        for indexPath in indexes
        {
            if let file = files?[indexPath.row], file.isAudio
            {
                stopDownloading(file)
                file.removeLocalFile()
                files?[indexPath.row] = file
            }
        }
        viewDelegate?.filesDidChange(viewModel: self)
    }
    
    func downloadFilesFor(_ indexes : [IndexPath])
    {
        for indexPath in indexes
        {
            let file = files?[indexPath.row]
            if (file?.isAudio)!
            {
                download(file!)
            }
        }
    }
}







