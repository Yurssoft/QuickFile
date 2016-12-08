//
//  YSPlaylistViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSPlaylistViewModel : YSPlaylistViewModelProtocol
{
    var model: YSPlaylistModelProtocol?
    {
        didSet
        {
            files = []
            folders = []
            model?.allFiles()
                { (folders, files, error) in
                    self.files = files
                    self.folders = folders
                    if let error = error
                    {
                        self.error = error
                    }
            }
        }
    }
    
    fileprivate var files: [YSDriveFileProtocol] = []
    {
        didSet
        {
            viewDelegate?.filesDidChange(viewModel: self)
        }
    }
    
    fileprivate var folders: [YSDriveFileProtocol] = []
    {
        didSet
        {
            viewDelegate?.filesDidChange(viewModel: self)
        }
    }
    
    var viewDelegate: YSPlaylistViewModelViewDelegate?
    
    var coordinatorDelegate: YSPlaylistViewModelCoordinatorDelegate?
    
    
    func numberOfFiles(in folder: Int) -> Int
    {
        let folder = folders[folder]
        let filesInFolder = files.filter
        {
            return $0.folder == folder.folder
        }
        return filesInFolder.count
    }
    
    var numberOfFolders: Int
    {
        return folders.count
    }
    
    var error : YSErrorProtocol = YSError.init()
    {
        didSet
        {
            if !error.isEmpty()
            {
                viewDelegate?.errorDidChange(viewModel: self, error: error)
            }
        }
    }
    
    func file(at index: Int, folderIndex: Int) -> YSDriveFileProtocol?
    {
        let folder = folders[index]
        let filesInFolder = files.filter
        {
            return $0.folder == folder.folder
        }
        return filesInFolder.count > 0 ? filesInFolder[index] : nil
    }
    
    func folder(at index: Int) -> YSDriveFileProtocol?
    {
        return folders[index]
    }
    
    func useFile(at index: Int)
    {
        
    }
    
    func removeDownloads()
    {
        
    }
    
    func getFiles(completion: @escaping CompletionHandler)
    {
        files = []
        folders = []
        model?.allFiles()
            { (folders, files, error) in
                self.files = files
                self.folders = folders
                if let error = error
                {
                    self.error = error
                }
        }
    }
    
    func index(of file : YSDriveFileProtocol, inFolder index : Int) -> Int
    {
        let folder = folders[index]
        let filesInFolder = files.filter
        {
            return $0.folder == folder.folder
        }
        if let index = filesInFolder.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier})
        {
            return index
        }
        return 0
    }
    
    func index(of folder : YSDriveFileProtocol) -> Int
    {
        if let index = folders.index(where: {$0.fileDriveIdentifier == folder.fileDriveIdentifier})
        {
            return index
        }
        return 0
    }
}
