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
            getFiles { (_) in
                
            }
        }
    }
    
    fileprivate var playlist: [String : [YSDriveFileProtocol]] = [:]
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
        let playlistFoldersKeys = [String](playlist.keys)
        let folderKey = playlistFoldersKeys[folder]
        if let filesInFolder = playlist[folderKey]
        {
            return filesInFolder.count - 1
        }
        return 0
    }
    
    var numberOfFolders: Int
    {
        let playlistFoldersKeys = [String](playlist.keys)
        return playlistFoldersKeys.count
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
        let playlistFoldersKeys = [String](playlist.keys)
        let folderKey = playlistFoldersKeys[folderIndex]
        if var filesInFolder = playlist[folderKey]
        {
            filesInFolder = filesInFolder.filter({ return $0.isAudio })
            return filesInFolder[index]
        }
        return nil
    }
    
    func folder(at index: Int) -> YSDriveFileProtocol?
    {
        let playlistFoldersKeys = [String](playlist.keys)
        let folderKey = playlistFoldersKeys[index]
        if var filesInFolder = playlist[folderKey]
        {
            filesInFolder = filesInFolder.filter({ return !$0.isAudio })
            return filesInFolder.first!
        }
        return nil
    }
    
    func useFile(at index: Int)
    {
        
    }
    
    func removeDownloads()
    {
        
    }
    
    func getFiles(completion: @escaping CompletionHandler)
    {
        playlist = [:]
        model?.allFiles()
            { (playlist, error) in
                self.playlist = playlist
                if let error = error
                {
                    self.error = error
                }
        }
    }
    
    func index(of file : YSDriveFileProtocol, inFolder index : Int) -> Int
    {
//        let folder = folders[index]
//        let filesInFolder = files.filter
//        {
//            return $0.folder == folder.folder
//        }
//        if let index = filesInFolder.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier})
//        {
//            return index
//        }
        return 0
    }
    
    func index(of folder : YSDriveFileProtocol) -> Int
    {
//        if let index = folders.index(where: {$0.fileDriveIdentifier == folder.fileDriveIdentifier})
//        {
//            return index
//        }
        return 0
    }
}
