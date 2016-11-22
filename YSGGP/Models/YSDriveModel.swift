//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

class YSDriveModel: NSObject, YSDriveModelProtocol
{
    var isLoggedIn : Bool
    {
        return YSCredentialManager.isLoggedIn
    }
    
    fileprivate var currentFolderID : String = ""
    
    init(folderID: String)
    {
        var folID = folderID
        if folID.isEmpty
        {
            folID = "root"
        }
        self.currentFolderID = folID
    }
    
    func getFiles(_ completionHandler: DriveCompletionHandler? = nil)
    {
        let url = "\(YSConstants.kDriveAPIEndpoint)files?corpus=user&orderBy=folder%2Cname&pageSize=100&q='\(currentFolderID)'+in+parents+and+(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed%3Dfalse&spaces=drive&fields=nextPageToken%2C+files(id%2C+name%2C+size%2C+mimeType)&key=\(YSConstants.kDriveAPIKey)"
        YSFilesMetadataDownloader.downloadFilesList(for: url)
        { filesDictionary, error in
            if let err = error
            {
                completionHandler!([], err)
                return
            }
            YSDatabaseManager.save(filesDictionary: filesDictionary!, self.currentFolderID, completionHandler)
        }
    }
    
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
    {
        return YSAppDelegate.appDelegate().fileDownloader?.download(for: file)
    }
    
    func download(_ file : YSDriveFileProtocol, _ progressHandler: DownloadFileProgressHandler? = nil, completionHandler : DownloadCompletionHandler? = nil)
    {
        YSAppDelegate.appDelegate().fileDownloader?.download(file: file, progressHandler, completionHandler: completionHandler)
    }
}
