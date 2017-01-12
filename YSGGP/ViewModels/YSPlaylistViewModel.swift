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
    var model: YSPlaylistAndPlayerModelProtocol?
    {
        didSet
        {
            getFiles { (_) in
                
            }
        }
    }
    
    fileprivate var files: [YSDriveFileProtocol] = [YSDriveFileProtocol]()
    
    var viewDelegate: YSPlaylistViewModelViewDelegate?
    
    var coordinatorDelegate: YSPlaylistViewModelCoordinatorDelegate?
    
    func numberOfFiles(in folder: Int) -> Int
    {
        let allFolders = folders()
        guard allFolders.count > folder else { return 0 }
        let folderFile = allFolders[folder]
        let filesInFolder = files.filter { $0.folder.folderID == folderFile.fileDriveIdentifier && $0.isAudio }
        return filesInFolder.count
    }
    
    var numberOfFolders: Int
    {
        return folders().count
    }
    
    func folders() -> [YSDriveFileProtocol]
    {
        let folders = files.filter()
            {
                let folderFile = $0
                if !folderFile.isAudio
                {
                    let filesInFolder = files.filter { $0.folder.folderID == folderFile.fileDriveIdentifier && $0.isAudio }
                    return filesInFolder.count > 0
                }
                else
                {
                    return false
                }
        }
        return folders
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
        let allFolders = folders()
        guard allFolders.count > folderIndex else { return nil }
        let folderFile = allFolders[folderIndex]
        let filesInFolder = files.filter { $0.folder.folderID == folderFile.fileDriveIdentifier && $0.isAudio }
        guard filesInFolder.count > index else { return nil }
        let file = filesInFolder[index]
        return file
    }
    
    func folder(at index: Int) -> YSDriveFileProtocol?
    {
        let allFolders = folders()
        guard allFolders.count > index else { return nil }
        let folderFile = allFolders[index]
        return folderFile
    }
    
    func useFile(at folder: Int, file: Int)
    {
        let audio = self.file(at: file, folderIndex: folder)
        coordinatorDelegate?.playlistViewModelDidSelectFile(self, file: audio!)
    }
    
    func removeDownloads()
    {
        
    }
    
    func getFiles(completion: @escaping CompletionHandler)
    {
        files = []
        model?.allFiles()
            { (files, error) in
                self.files = files
                if let error = error
                {
                    self.error = error
                }
                DispatchQueue.main.async
                {
                    completion(error)
                }
        }
    }
}
