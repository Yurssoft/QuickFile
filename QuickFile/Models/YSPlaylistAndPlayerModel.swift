//
//  YSPlaylistModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSPlaylistAndPlayerModel: YSPlaylistAndPlayerModelProtocol {
    func allFiles(_ completionHandler: @escaping AllFilesAndCurrentPlayingCH) {
        YSDatabaseManager.allFilesWithCurrentPlaying { (databaseYSFiles, currentPlaying, yserror) in
            if let error = yserror {
                completionHandler([], nil, error)
            }
            let allFiles = databaseYSFiles.filter { $0.localFileExists() || !$0.isAudio }
            completionHandler(allFiles, currentPlaying, nil)
        }
    }
}
