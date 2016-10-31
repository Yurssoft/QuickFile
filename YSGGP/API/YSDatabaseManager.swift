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
            printDB(ref: ref)
            completionHandler!(files, YSError())
        }
        else
        {
            let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.info, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
            completionHandler!([], error)
        }
    }
    
    private static func printDB(ref: FIRDatabaseReference)
    {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let allFiles = value?["files"] as? NSDictionary
            let files = allFiles?["root"] as? NSArray
            print(files)
        })
    }
}
