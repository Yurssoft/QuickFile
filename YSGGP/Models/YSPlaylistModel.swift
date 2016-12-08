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
                for dbFile in databaseYSFiles
                {
                    dbFile.isAudio ? files.append(dbFile) : folders.append(dbFile)
                }
                let rootFolder = YSDriveFile.init(fileName: "Root", fileSize: "", mimeType: "application/yurssoft.root.folder", fileDriveIdentifier: UUID().uuidString, folder: "root")
                folders.append(rootFolder)
                var playlistDictionary = [String : [YSDriveFileProtocol]]()
                for folder in folders
                {
                    var filesInFolder = files.filter { return $0.folder == folder.folder }
                    filesInFolder.append(folder)
                    playlistDictionary[folder.folder] = filesInFolder
                }
                completionHandler(playlistDictionary, nil)
        }
    }
}
