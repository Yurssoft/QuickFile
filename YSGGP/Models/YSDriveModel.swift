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
        var url = ""
        YSFilesMetadataDownloader.downloadFilesList(for: url)
        { filesDictionary, error in
            if let err = error
            {
                completionHandler!([], err)
                return
            }
            
            YSDatabaseManager.save(filesDictionary: filesDictionary!, self.currentFolderID, completionHandler)
        }
//            YSDriveManager.shared.service.executeQuery(query, completionHandler: { (ticket, response1, error) in
//                if error != nil
//                {
//                    if (error?.localizedDescription.contains("appears to be offline"))!
//                    {
//                        let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Warning", message: "Could not get list offline", buttonTitle: "Try again", debugInfo: error.debugDescription)
//                        YSDatabaseManager.getFiles(folderID: self.currentFolderID, errorMessage, completionHandler)
//                        return
//                    }
//                    let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.error, title: "Error", message: "Couldn't get data from Drive", buttonTitle: "Try again", debugInfo: error.debugDescription)
//                    completionHandler!(ysfiles, errorMessage)
//                    return
//                }
//                let response = response1 as? GTLRDrive_FileList
//                if let files = response?.files , !files.isEmpty
//                {
//                    for file in files
//                    {
//                        let ysfile = YSDriveFile(file: file, folder: self.currentFolderID)
//                        ysfile.isFileOnDisk = ysfile.localFileExists()
//                        ysfiles.append(ysfile)
//                    }
//                    YSDatabaseManager.save(files: ysfiles, completionHandler)
//                }
//                else
//                {
//                    completionHandler!([], YSError())
//                }
//            })
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
