//
//  YSDatabaseManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/31/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import Firebase
import SwiftMessages

class YSDatabaseManager
{
    static func save(files: [YSDriveFileProtocol], folderID: String, _ completionHandler: DriveCompletionHandler? = nil)
    {
        if (FIRAuth.auth()?.currentUser) != nil
        {
            var ref: FIRDatabaseReference!
            ref = FIRDatabase.database().reference()
            
            var dictionaryFiles = [String : [String: Any]]()
            
            for file in files
            {
                let mirroredFile = Mirror(reflecting: file)
                
                var fileDict = [String: Any]()
                for (_, attr) in mirroredFile.children.enumerated()
                {
                    if let property_name = attr.label as String!
                    {
                        fileDict[property_name] = attr.value
                    }
                }
                let identifier = fileDict["fileDriveIdentifier"] as! String
                dictionaryFiles[identifier] = fileDict
            }
            ref.child("files").child(folderID).setValue(dictionaryFiles)
            completionHandler!(files, YSError())
        }
        else
        {
            let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.info, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
            completionHandler!([], error)
        }
    }
    
    static func getFiles(folderID: String,_ error: YSError,_ completionHandler: DriveCompletionHandler? = nil)
    {
        if (FIRAuth.auth()?.currentUser) != nil
        {
            var ref: FIRDatabaseReference!
            ref = FIRDatabase.database().reference(withPath: "files/\(folderID)")
            
            ref.queryLimited(toLast: 150).observe(.value, with: { (snapshot) in
                let DBfiles = snapshot.value as! [String : [String: Any]]
                var files = [YSDriveFileProtocol]()
                for key in DBfiles.keys
                {
                    let dbFile = DBfiles[key]
                    let ysFile = YSDriveFile()
                    for key in (dbFile?.keys)!
                    {
                        let val = dbFile?[key]
                        ysFile.setValue(val, forKey: key)
                    }
                    files.append(ysFile)
                }
                let sortedFiles = files.sorted(by: { (_ f1,_ f2) -> Bool in
                    return f1.isAudio == f2.isAudio ? f1.fileName < f2.fileName : !f1.isAudio
                })
                completionHandler!(sortedFiles, error)
            })
        }
        else
        {
            completionHandler!([], error)
        }
    }
}
