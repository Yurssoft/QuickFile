//
//  YSDriveFile.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class YSDriveFile : NSObject, YSDriveFileProtocol
{
    var fileName : String //Book 343
    var fileSize : String //108.03 MB (47 audio) or 10:18
    var mimeType : String
    var isAudio : Bool
    var fileDriveIdentifier : String
    var localFilePath : String = ""
    var modifiedTime : String = ""
    
    init(fileName : String?, fileSize : String?, mimeType : String?, isAudio : Bool, fileDriveIdentifier : String?)
    {
        self.fileName = YSDriveFile.checkStringForNil(string: fileName)
        self.fileSize = YSDriveFile.checkStringForNil(string: fileSize)
        self.isAudio = isAudio
        self.mimeType = YSDriveFile.checkStringForNil(string: mimeType)
        self.fileDriveIdentifier = YSDriveFile.checkStringForNil(string: fileDriveIdentifier)
    }
    
    override init()
    {
        self.fileName = ""
        self.fileSize = ""
        self.isAudio = false
        self.mimeType = ""
        self.fileDriveIdentifier = ""
    }
    
    required init(file: GTLRDrive_File)
    {
        self.fileName = YSDriveFile.checkStringForNil(string: file.name)
        self.fileSize = YSDriveFile.checkStringForNil(string: file.size == nil ? "" : file.size?.stringValue)
        let isAudio = file.mimeType != nil && (file.mimeType?.contains("audio"))!
        self.isAudio = isAudio
        self.mimeType = YSDriveFile.checkStringForNil(string: file.mimeType)
        self.fileDriveIdentifier = YSDriveFile.checkStringForNil(string: file.identifier)
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
