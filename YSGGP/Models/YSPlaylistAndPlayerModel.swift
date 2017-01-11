//
//  YSPlaylistModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSPlaylistAndPlayerModel : YSPlaylistAndPlayerModelProtocol
{
    func allFiles(_ completionHandler: @escaping DriveCompletionHandler)
    {
        YSDatabaseManager.allFiles
        { (databaseYSFiles, yserror) in
            if let error = yserror
            {
                completionHandler([], error)
            }
            let allFiles = databaseYSFiles.filter { $0.isFileOnDisk || !$0.isAudio }
            completionHandler(allFiles, nil)
        }
    }
}
