//
//  YSPlaylistModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSPlaylistModel : YSPlaylistModelProtocol
{
    func allFiles(_ completionHandler: @escaping PlaylistCompletionHandler)
    {
        YSDatabaseManager.allFiles
            { (databaseYSFiles, yserror) in
                if let error = yserror
                {
                    completionHandler([:], error)
                }
                var folders = [YSDriveFileProtocol]()
                var files = [YSDriveFileProtocol]()
                let databaseYSFiles = databaseYSFiles.filter { return $0.isFileOnDisk || !$0.isAudio }
                for dbFile in databaseYSFiles
                {
                    if dbFile.isAudio && dbFile.isFileOnDisk
                    {
                        files.append(dbFile)
                    }
                    if !dbFile.isAudio
                    {
                        let filesInFolder = databaseYSFiles.filter { return $0.folder.folderID == dbFile.fileDriveIdentifier && $0.isAudio }
                        if filesInFolder.count > 0
                        {
                            folders.append(dbFile)
                        }
                    }
                }
                let filesInRootFolder = files.filter { return $0.folder.folderID == YSFolder.rootFolder().folderID }
                if filesInRootFolder.count > 0
                {
                    let rootFolder = YSDriveFile.init(fileName: "Root", fileSize: "", mimeType: "application/yurssoft.root.folder", fileDriveIdentifier: UUID().uuidString, folderName: "Root", folderID: "root")
                    folders.append(rootFolder)
                }
                var playlistDictionary = [String : [YSDriveFileProtocol]]()
                for folder in folders
                {
                    var filesInFolder = files.filter { return $0.folder.folderID == folder.fileDriveIdentifier && $0.isAudio }
                    filesInFolder.append(folder)
                    if filesInFolder.count > 0
                    {
                        playlistDictionary[folder.fileDriveIdentifier] = filesInFolder
                    }
                }
                completionHandler(playlistDictionary, nil)
        }
    }
}
