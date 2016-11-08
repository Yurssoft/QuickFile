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
    private static let completionBlockDelay = 0.3
    static func initialize()
    {
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
    }
    
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
//                let rules = ["rules" : [identifier:["indexOn":"isAudio, fileName"]]]
//                print(rules)
//                ref.child("files").setValue(rules)
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
            ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                if currentData.hasChildren()
                {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in currentData.children
                    {
                        let databaseFile = currentDatabaseFile as! FIRMutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        let ysFile = YSDriveFile()
                        for key in dbFile.keys
                        {
                            let val = dbFile[key]
                            ysFile.setValue(val, forKey: key)
                        }
                        files.append(ysFile)
                    }
                    let sortedFiles = files.sorted(by: { (_ file1,_ file2) -> Bool in
                        return file1.isAudio == file2.isAudio ? file1.fileName < file2.fileName : !file1.isAudio
                    })
                    callCompletionHandler(completionHandler, files: sortedFiles, error)
                }
                else
                {
                    callCompletionHandler(completionHandler, files: [], error)
                }
                return FIRTransactionResult.success(withValue: currentData)
            }) { (nserror, committed, snapshot) in
                callCompletionHandler(completionHandler, files: [], error)
            }
        }
        else
        {
            callCompletionHandler(completionHandler, files: [], error)
        }
    }
    
    static func callCompletionHandler(_ completionHandler: DriveCompletionHandler?, files : [YSDriveFileProtocol], _ error: YSError)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + completionBlockDelay)
        {
            completionHandler!(files, error)
        }
    }
}
