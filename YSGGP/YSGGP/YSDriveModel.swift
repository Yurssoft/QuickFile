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
        return service.authorizer != nil
    }
    
    let service = GTLServiceDrive()
    
    func items(_ completionhandler: @escaping (_ items: [YSDriveItem], _ error : Error?) -> ())
    {
        let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName:  YSConstants.kDriveKeychainItemName,
            clientID: YSConstants.kDriveClientID,
            clientSecret: nil)
        do
        {
            try GTMOAuth2ViewControllerTouch.authorizeFromKeychain(forName:YSConstants.kDriveKeychainItemName, authentication: auth)
        }
        catch
        {
            print("error drive login \(error.localizedDescription)")
        }
        if auth != nil && (auth?.canAuthorize)!
        {
            service.authorizer = auth
            let query = GTLQueryDrive.queryForFilesList()
            query?.pageSize = 10
            query?.fields = "nextPageToken, files(id, name)"
            
            var items : [YSDriveItem]
            items = []
            service.executeQuery(query!, completionHandler: { (ticket, response1, error) in
                let response = response1 as? GTLDriveFileList
                if let files = response?.files , !files.isEmpty
                {
                    for file in files as! [GTLDriveFile]
                    {
                        let item = YSDriveItem(fileName: file.name, fileInfo: file.identifier, fileURL: file.size.stringValue, isAudio: false)
                        items.append(item)
                    }
                    completionhandler(items, error)
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
            let error = NSError(domain: YSDriveModel.nameOfClass,
                              code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Login to drive first!"])
            completionhandler(items, error)
        }
    }
}
