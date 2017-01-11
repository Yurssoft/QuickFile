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
        let folders = files.filter{ !$0.isAudio }
        guard folders.count > folder else { return 0 }
        let folderFile = folders[folder]
        let filesInFolder = files.filter { $0.folder.folderID == folderFile.fileDriveIdentifier && $0.isAudio }
        return filesInFolder.count
    }
    
    var numberOfFolders: Int
    {
        let folders = files.filter{ !$0.isAudio }
        //TODO: do not show folder if no files in there
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
        let folders = files.filter{ !$0.isAudio }
        guard folders.count > folderIndex else { return nil }
        let folderFile = folders[folderIndex]
        let filesInFolder = files.filter { $0.folder.folderID == folderFile.fileDriveIdentifier && $0.isAudio }
        guard filesInFolder.count > index else { return nil }
        let file = filesInFolder[index]
        return file
    }
    
    func folder(at index: Int) -> YSDriveFileProtocol?
    {
        let folders = files.filter{ !$0.isAudio }
        guard folders.count > index else { return nil }
        let folderFile = folders[index]
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
