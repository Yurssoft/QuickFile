//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GTMOAuth2
import SwiftMessages

class YSDriveModel: NSObject, YSDriveModelProtocol
{
    var isLoggedIn : Bool
    {
        return YSDriveManager.shared.isLoggedIn
    }
    
    fileprivate var currentFolderID : String = ""
    
    init(folderID: String)
    {
        self.currentFolderID = folderID
    }
    
    func getFiles(_ completionHandler: DriveCompletionHandler? = nil)
    {
        if completionHandler == nil
        {
            return
        }
        YSDriveManager.shared.login()
        if isLoggedIn
        {
            let query = GTLRDriveQuery_FilesList.query()
            query.pageSize = 100
            query.fields = "nextPageToken, files(id, name, size, mimeType)"
            query.spaces = "drive"
            query.q = "mimeType contains 'folder' or mimeType contains 'audio'"
            if currentFolderID.isEmpty
            {
                query.q = "'root' in parents and (mimeType contains 'folder' or mimeType contains 'audio')"
            }
            else
            {
                query.q = NSString(format: "'%@' in parents and (mimeType contains 'folder' or mimeType contains 'audio')", currentFolderID) as String!
            }
            var ysfiles : [YSDriveFileProtocol] = []
            
            YSDriveManager.shared.service.executeQuery(query, completionHandler: { (ticket, response1, error) in
                if error != nil
                {
                    let error = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.error, title: "Error", message: "Couldn't get data from Drive", buttonTitle: "Try again", debugInfo: error.debugDescription)
                    completionHandler!(ysfiles, error)
                    return
                }
                let response = response1 as? GTLRDrive_FileList
                if let files = response?.files , !files.isEmpty
                {
                    for file in files
                    {
                        let isAudio = file.mimeType != nil && (file.mimeType?.contains("audio"))!
                        let ysfile = YSDriveFile(fileName: file.name,
                                                 fileSize: file.size?.stringValue,
                                                 mimeType: file.mimeType,
                                                 isAudio: isAudio,
                                                 fileDriveIdentifier: file.identifier)
                        ysfiles.append(ysfile)
                    }
                    completionHandler!(ysfiles, YSError())
                }
                else
                {
                    completionHandler!([], YSError())
                }
            })
        }
        else
        {
            let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.info, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
            completionHandler!([], error)
        }
    }
}
