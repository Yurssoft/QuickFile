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
    
    static func save(filesDictionary: [String : [String: Any]],_ folder : String, _ completionHandler: DriveCompletionHandler? = nil)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: FIRMutableData) -> FIRTransactionResult in
                
                var dbFilesDict = databaseFilesDictionary(from: dbFiles)
                var dbFilesForFolder = [String : [String: Any]]()
                for key in dbFilesDict.keys
                {
                    var dbFile = dbFilesDict[key]
                    let dbFileFolder = dbFile?["folder"] as! String
                    if dbFileFolder == folder
                    {
                        dbFilesForFolder[key] = dbFile
                        dbFilesDict[key] = nil
                    }
                }
                var ysfiles : [YSDriveFileProtocol] = []
                for fileIdentifier in filesDictionary.keys
                {
                    let fileDict = filesDictionary[fileIdentifier]
                    
                    var ysFile = convert(fileDictionary: fileDict!)
                    ysFile.isFileOnDisk = ysFile.localFileExists()
                    
                    ysfiles.append(ysFile)
                    dbFilesDict[fileIdentifier] = fileDict
                }

                ref.child("files").setValue(dbFilesDict)

                completionHandler!(sortFiles(ysFiles: ysfiles), YSError())
                
                return FIRTransactionResult.abort()
            })
        }
        else
        {
            let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.info, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
            completionHandler!([], error)
        }
    }

    static func getFiles(folderID: String,_ error: YSError,_ completionHandler: DriveCompletionHandler? = nil)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: FIRMutableData) -> FIRTransactionResult in
                var sortedFiles : [YSDriveFileProtocol] = []
                if dbFiles.hasChildren()
                {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in dbFiles.children
                    {
                        let databaseFile = currentDatabaseFile as! FIRMutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        var ysFile = convert(fileDictionary: dbFile)
                        if ysFile.folder == folderID
                        {
                            ysFile.isFileOnDisk = ysFile.localFileExists()
                            files.append(ysFile)
                        }
                    }
                    sortedFiles = sortFiles(ysFiles: files)
                }
                callCompletionHandler(completionHandler, files: sortedFiles, error)
                return FIRTransactionResult.abort()
            })
        }
        else
        {
            callCompletionHandler(completionHandler, files: [], error)
        }
    }
    
    static func update(file: YSDriveFileProtocol)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files/\(file.fileDriveIdentifier)").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                let updatedFile = convert(ysFile: file)
                
                ref.child("files/\(file.fileDriveIdentifier)").updateChildValues(updatedFile)
                return FIRTransactionResult.abort()
            })
        }
    }
    
    private static func sortFiles(ysFiles: [YSDriveFileProtocol]) -> [YSDriveFileProtocol]
    {
        let sortedFiles = ysFiles.sorted(by: { (_ file1,_ file2) -> Bool in
            return file1.isAudio == file2.isAudio ? file1.fileName < file2.fileName : !file1.isAudio
        })
        return sortedFiles
    }
    
    private static func convert(ysFile: YSDriveFileProtocol) -> [String: Any]
    {
        let mirroredFile = Mirror(reflecting: ysFile)
        
        var fileDict = [String: Any]()
        for (_, attr) in mirroredFile.children.enumerated()
        {
            if let property_name = attr.label as String!
            {
                fileDict[property_name] = attr.value
            }
        }
        return fileDict
    }
    
    private static func convert(fileDictionary: [String : Any]) -> YSDriveFileProtocol
    {
        let ysFile = YSDriveFile()
        for key in fileDictionary.keys
        {
            if key == "rules"
            {
                continue
            }
            let val = fileDictionary[key]
            ysFile.setValue(val, forKey: key)
        }
        return ysFile
    }
    
    private static func databaseFilesDictionary(from databaseFiles: FIRMutableData) -> [String : [String: Any]]
    {
        var databaseFilesDictionary = [String : [String: Any]]()
        for currentDatabaseFile in databaseFiles.children
        {
            let databaseFile = currentDatabaseFile as! FIRMutableData
            let dbFile = databaseFile.value as! [String : Any]
            let fileDriveIdentifier = dbFile["fileDriveIdentifier"] as! String
            databaseFilesDictionary[fileDriveIdentifier] = dbFile
        }
        return databaseFilesDictionary
    }
    
    
    private static func referenceForCurrentUser() -> FIRDatabaseReference?
    {
        if (FIRAuth.auth()?.currentUser) != nil, let uud = FIRAuth.auth()?.currentUser?.uid
        {
            let ref = FIRDatabase.database().reference(withPath: "users/\(uud)")
            return ref
        }
        return nil
    }
    
    private static func callCompletionHandler(_ completionHandler: DriveCompletionHandler?, files : [YSDriveFileProtocol], _ error: YSError)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + completionBlockDelay)
        {
            completionHandler!(files, error)
        }
    }
}
