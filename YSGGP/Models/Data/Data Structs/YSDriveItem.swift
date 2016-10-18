//
//  YSDriveItem.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSDriveItem : YSDriveItemProtocol
{
    let fileName : String //Book 343
    let fileInfo : String //108.03 MB (47 audio) or 10:18
    let fileURL : String
    let isAudio : Bool
    
    init(fileName : String, fileInfo : String, fileURL : String, isAudio : Bool)
    {
        self.fileName = fileName
        self.fileInfo = fileInfo
        self.isAudio = isAudio
        self.fileURL = fileURL
    }
}
