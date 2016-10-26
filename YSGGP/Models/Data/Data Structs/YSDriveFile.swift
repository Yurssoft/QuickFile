//
//  YSDriveFile.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSDriveFile : YSDriveFileProtocol
{
    let fileName : String //Book 343
    let fileSize : String //108.03 MB (47 audio) or 10:18
    let mimeType : String
    let isAudio : Bool
    let fileDriveIdentifier : String
    var localFilePath : String = ""
    
    init(fileName : String?, fileSize : String?, mimeType : String?, isAudio : Bool, fileDriveIdentifier : String?)
    {
        self.fileName = YSDriveFile.checkStringForNil(string: fileName)
        self.fileSize = YSDriveFile.checkStringForNil(string: fileSize)
        self.isAudio = isAudio
        self.mimeType = YSDriveFile.checkStringForNil(string: mimeType)
        self.fileDriveIdentifier = YSDriveFile.checkStringForNil(string: fileDriveIdentifier)
    }
    
    static func checkStringForNil(string : String?) -> String
    {
        if string == nil
        {
            return ""
        }
        return string!
    }
}
