//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

class YSDriveModel: YSDriveModelProtocol
{
    var isLoggedIn : Bool
    {
        return YSCredentialManager.isLoggedIn
    }
    
    fileprivate var currentFolder : YSFolder = YSFolder()
    
    init(folder: YSFolder)
    {
        currentFolder = folder
    }
    
    func getFiles(_ completionHandler: @escaping AllFilesCompletionHandler)
    {
        let url = "\(YSConstants.kDriveAPIEndpoint)files?corpus=user&orderBy=folder%2Cname&pageSize=100&q='\(currentFolder.folderID)'+in+parents+and+(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed%3Dfalse&spaces=drive&fields=nextPageToken%2C+files(id%2C+name%2C+size%2C+mimeType)&key=\(YSConstants.kDriveAPIKey)"
        YSFilesMetadataDownloader.downloadFilesList(for: url)
        { filesDictionary, error in
            if let err = error
            {
                let yserror = err as! YSError
                YSDatabaseManager.files(for: self.currentFolder, yserror, completionHandler)
                return
            }
            YSDatabaseManager.save(remoteFilesDict: filesDictionary!, self.currentFolder, completionHandler)
        }
    }
    
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
    {
        return YSAppDelegate.appDelegate().fileDownloader?.download(for: file)
    }
    
    func download(_ file : YSDriveFileProtocol)
    {
        YSAppDelegate.appDelegate().fileDownloader?.download(file: file)
    }
    
    func stopDownload(_ file : YSDriveFileProtocol)
    {
        YSAppDelegate.appDelegate().fileDownloader?.cancelDownloading(file: file)
    }
}
