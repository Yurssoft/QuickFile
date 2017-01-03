//
//  YSDriveFile.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSDriveFile : NSObject, YSDriveFileProtocol
{
    var fileName : String //Book 343
    var fileSize : String //108.03 MB (47 audio) or 10:18
    var mimeType : String
    var isAudio : Bool
    var fileDriveIdentifier : String
    var modifiedTime : String = ""
    var isFileOnDisk : Bool = false
    var folder : YSFolder = YSFolder()
    
    init(fileName : String?, fileSize : String?, mimeType : String?, fileDriveIdentifier : String?, folderName : String?, folderID : String?)
    {
        self.fileName = YSDriveFile.checkStringForNil(string: fileName)
        self.fileSize = YSDriveFile.checkStringForNil(string: fileSize)
        self.mimeType = YSDriveFile.checkStringForNil(string: mimeType)
        let mimeTypes = YSDriveFile.checkStringForNil(string: mimeType)
        if !mimeTypes.isEmpty && (mimeTypes.contains("mp3") || mimeTypes.contains("audio") || mimeTypes.contains("mpeg"))
        {
            self.isAudio = true
        }
        else
        {
            self.isAudio = false
        }
        self.fileDriveIdentifier = YSDriveFile.checkStringForNil(string: fileDriveIdentifier)
        self.folder.folderName = YSDriveFile.checkStringForNil(string: folderName)
        self.folder.folderID = YSDriveFile.checkStringForNil(string: folderID)
    }
    
    override init()
    {
        self.fileName = ""
        self.fileSize = ""
        self.isAudio = false
        self.mimeType = ""
        self.fileDriveIdentifier = ""
    }
    
    class func checkStringForNil(string : String?) -> String
    {
        if string == nil
        {
            return ""
        }
        return string!
    }
    
    func fileUrl() -> String
    {
        return String(format: "%@files/%@?alt=media&key=%@", YSConstants.kDriveAPIEndpoint, fileDriveIdentifier, YSConstants.kDriveAPIKey)
    }
    
    func localFilePath() -> URL?
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        if let url = URL(string: fileUrl())
        {
            if url.lastPathComponent.isEmpty
            {
                return nil
            }
            var fullPath = documentsPath.appendingPathComponent(url.lastPathComponent)
            fullPath = "\(fullPath).mp3"
            return URL(fileURLWithPath:fullPath)
        }
        return nil
    }
    
    func localFileExists() -> Bool
    {
        var isDir : ObjCBool = false
        if let path = localFilePath()?.path
        {
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            self.isFileOnDisk = exists
            return exists
        }
        self.isFileOnDisk = false
        return false
    }
    
    func removeLocalFile()
    {
        try? FileManager.default.removeItem(at: localFilePath()!)
        self.isFileOnDisk = false
    }
}
