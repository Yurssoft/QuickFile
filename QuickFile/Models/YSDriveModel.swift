//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages
import NSLogger

class YSDriveModel: YSDriveModelProtocol
{
    var isLoggedIn : Bool
    {
        return YSCredentialManager.isLoggedIn
    }
    
    private var currentFolder : YSFolder?
    private let taskUIID = UUID().uuidString
    
    init(folder: YSFolder?)
    {
        currentFolder = folder
    }
    
    deinit
    {
        YSFilesMetadataDownloader.cancelTaskWithIdentifier(taskIdentifier: taskUIID)
    }
    
    func getFiles(pageToken: String, nextPageToken: String?,_ completionHandler: @escaping AllFilesCompletionHandler)
    {
        var url = "\(YSConstants.kDriveAPIEndpoint)files?"
        url.addingPercentEncoding(nextPageToken)
        guard let folder = currentFolder else
        {
            Log(.Service, .Error, "No folder")
            return
        }
        url += "corpus=user&orderBy=folder%2Cname&pageSize=\(YSConstants.kPageSize)&q='\(folder.folderID)'+in+parents+and+(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed%3Dfalse&spaces=drive&fields=nextPageToken%2C+files(id%2C+name%2C+size%2C+mimeType)&key=\(YSConstants.kDriveAPIKey)"
        YSFilesMetadataDownloader.downloadFilesList(for: url, taskUIID)
        { filesDictionary, error in
            if let err = error
            {
                let yserror = err as! YSError
                YSDatabaseManager.offlineFiles(fileDriveIdentifier: folder.folderID, yserror, completionHandler)
                return
            }
            YSDatabaseManager.save(pageToken: pageToken, remoteFilesDict: filesDictionary!, folder, completionHandler)
        }
    }
    
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    {
        return YSAppDelegate.appDelegate().fileDownloader.download(for: fileDriveIdentifier)
    }
    
    func download(_ fileDriveIdentifier: String)
    {
        YSAppDelegate.appDelegate().fileDownloader.download(fileDriveIdentifier: fileDriveIdentifier)
    }
    
    func stopDownload(_ fileDriveIdentifier: String)
    {
        YSAppDelegate.appDelegate().fileDownloader.cancelDownloading(fileDriveIdentifier: fileDriveIdentifier)
    }
}
