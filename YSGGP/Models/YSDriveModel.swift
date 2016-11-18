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
        //https://www.googleapis.com/drive/v3/files?corpus=domain&orderBy=folder%2Cname&pageSize=100&q='root'+in+parents+&spaces=drive&fields=files(name%2Csize)&key={YOUR_API_KEY}
        //let url = "\(YSConstants.kDriveAPIEndpoint)files?corpus=user&orderBy=folder%2Cname&pageSize=100&q='\(currentFolderID)'+in+parents+and+(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed%3Dfalse&spaces=drive&fields=nextPageToken%2C+files(id%2C+name%2C+size%2C+mimeType)&key=\(YSConstants.kDriveAPIKey)"
        let url = "https://www.googleapis.com/drive/v3/files?corpus=domain&orderBy=folder%2Cname&pageSize=100&q='root'+in+parents+and+(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed%3Dfalse&spaces=drive&fields=nextPageToken%2Cfiles(id%2Cname%2Csize%2CmimeType)&key=AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqa"
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
