//
//  YSPlayerModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSPlayerModel : YSPlayerModelProtocol
{
    //TODO: make the same sorting as in playlist
    func allFiles(_ completionHandler: @escaping YSPlayerCompletionHandler)
    {
        YSDatabaseManager.allFiles
        { (databaseYSFiles, yserror) in
            if let error = yserror
            {
                completionHandler([], error)
            }
            let files = databaseYSFiles.filter{ return $0.isAudio && $0.isFileOnDisk }
            completionHandler(files, nil)
        }
    }
}
