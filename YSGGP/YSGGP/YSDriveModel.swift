//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClient
import GTMOAuth2

class YSDriveModel: NSObject, YSDriveModelProtocol
{
    var isLoggedIn : Bool
    {
        return YSDriveManager.sharedInstance.isLoggedIn
    }
    
    func items(_ completionhandler: @escaping (_ items: [YSDriveItem], _ error : YSError?) -> ())
    {
        YSDriveManager.sharedInstance.login()
        if isLoggedIn
        {
            let query = GTLQueryDrive.queryForFilesList()
            query?.pageSize = 10
            query?.fields = "nextPageToken, files(id, name)"
            
            var items : [YSDriveItem]
            items = []
            YSDriveManager.sharedInstance.service.executeQuery(query!, completionHandler: { (ticket, response1, error) in
                let response = response1 as? GTLDriveFileList
                if let files = response?.files , !files.isEmpty
                {
                    for file in files as! [GTLDriveFile]
                    {
                        let item = YSDriveItem(fileName: file.name, fileInfo: file.identifier, fileURL: file.size.stringValue, isAudio: false)
                        items.append(item)
                    }
                    if !(error?.localizedDescription.isEmpty)!
                    {
                        completionhandler(items, YSError.couldNotGetFileList)
                    }
                    completionhandler(items, YSError.none)
                }
            })
        }
        else
        {
            var items : [YSDriveItem]
            items = []
            for i in (0..<200)
            {
                let item = YSDriveItem(fileName: "\(i)", fileInfo: "\(i)", fileURL:"\(i)", isAudio: false)
                items.append(item)
            }
            completionhandler(items, YSError.notLoggedInToDrive)
        }
    }
}
