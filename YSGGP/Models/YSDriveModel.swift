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
        return YSDriveManager.sharedInstance.isLoggedIn
    }
    
    func items(_ completionHandler: (([YSDriveItem], YSError?) -> Swift.Void)? = nil)
    {
        if completionHandler == nil
        {
            return
        }
        YSDriveManager.sharedInstance.login()
        if isLoggedIn
        {
            let query = GTLRDriveQuery_FilesList.query()
            query.pageSize = 10
            query.fields = "nextPageToken, files(id, name, size, mimeType)"
            query.spaces = "drive"
            query.q = NSString(format: "mimeType contains 'folder' or mimeType contains 'audio'") as String!
            
            var items : [YSDriveItem] = []
            YSDriveManager.sharedInstance.service.executeQuery(query, completionHandler: { (ticket, response1, error) in
                if error != nil
                {
                    let error = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.error, title: "Error", message: "Couldn't get data from Drive", buttonTitle: "Try again", debugInfo: error.debugDescription)
                    completionHandler!(items, error)
                    return
                }
                let response = response1 as? GTLRDrive_FileList
                if let files = response?.files , !files.isEmpty
                {
                    for file in files
                    {
                        let fileSize = file.size == nil ? "" : file.size?.stringValue
                        let isAudio = file.mimeType != nil && (file.mimeType?.contains("audio"))!
                        let item = YSDriveItem(fileName: file.name!, fileInfo: file.identifier!, fileURL: fileSize!, isAudio: isAudio)
                        items.append(item)
                    }
                    completionHandler!(items, YSError())
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
