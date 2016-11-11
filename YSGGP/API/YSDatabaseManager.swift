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
    
    static func save(files: [YSDriveFileProtocol], _ completionHandler: DriveCompletionHandler? = nil)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                var dictionaryFiles = [String : [String: Any]]()
                
                for file in files
                {
                    var fileDict = convert(ysFile: file)
                    let identifier = fileDict["fileDriveIdentifier"] as! String
                    fileDict["rules"] = ["indexOn":"isAudio, fileName"]
                    dictionaryFiles[identifier] = fileDict
                }
                let (updatedFiles, databaseFilesToDelete) = update(filesToUpdate: dictionaryFiles, with: currentData)
                
                if !databaseFilesToDelete.isEmpty
                {
                    var fileDBIdentifiersToDelete = [String : Any]()
                    for key in databaseFilesToDelete.keys
                    {
                        let dbFile = databaseFilesToDelete[key]
                        let fileDBIdentifier = dbFile?["fileDriveIdentifier"] as! String
                        fileDBIdentifiersToDelete[fileDBIdentifier] = NSNull()
                    }
                    ref.updateChildValues(fileDBIdentifiersToDelete)
                }
                ref.child("files").setValue(updatedFiles)
                { error , _ in
                    print("Database error \(error)")
                }
                var updatedFilesArray = [YSDriveFileProtocol]()
                
                
                for uldatedFileDictionary in updatedFiles
                {
                    let uldatedFileDict = uldatedFileDictionary.value
                    let ysFile = convert(fileDictionary: uldatedFileDict)
                    updatedFilesArray.append(ysFile)
                }
                let sortedFiles = updatedFilesArray.sorted(by: { (_ file1,_ file2) -> Bool in
                    return file1.isAudio == file2.isAudio ? file1.fileName < file2.fileName : !file1.isAudio
                })
                completionHandler!(sortedFiles, YSError())
                
                return FIRTransactionResult.abort()
            })
        }
        else
        {
            let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.info, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
            completionHandler!([], error)
        }
    }
    
    static func convert(ysFile: YSDriveFileProtocol) -> [String: Any]
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
    
    static func convert(fileDictionary: [String : Any]) -> YSDriveFileProtocol
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
    
    static func getFiles(folderID: String,_ error: YSError,_ completionHandler: DriveCompletionHandler? = nil)
    {
        if let ref = referenceForCurrentUser()
        {
//            let query = ref.child("files").queryOrdered(byChild: "folder").queryEqual(toValue: folderID, childKey: "folder").observe(.value, with: { (snap) in
//                print(snap)
//            })
            ref.child("files").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                
                if currentData.hasChildren()
                {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in currentData.children
                    {
                        let databaseFile = currentDatabaseFile as! FIRMutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        let ysFile = convert(fileDictionary: dbFile)
                        if ysFile.folder == folderID
                        {
                            files.append(ysFile)
                        }
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
    
    static func update(filesToUpdate: [String : [String: Any]], with dbFiles: FIRMutableData) -> ([String : [String: Any]], [String : [String: Any]])
    {
        var files = filesToUpdate
        var databaseFiles = databaseFilesDictionary(from: dbFiles)
        for key in files.keys
        {
            var file = files[key]!
            let fileDriveIdentifier = file["fileDriveIdentifier"] as! String
            if let databaseFile = databaseFiles[fileDriveIdentifier]
            {
                files[key]?["isFileOnDisk"] = databaseFile["isFileOnDisk"]
                databaseFiles.removeValue(forKey: fileDriveIdentifier)
            }
        }
        let databaseFilesToDelete = databaseFiles
        return (files, databaseFilesToDelete)
    }
    
    static func databaseFilesDictionary(from databaseFiles: FIRMutableData) -> [String : [String: Any]]
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
    
    static func update(file: YSDriveFileProtocol)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files/\(file.fileDriveIdentifier)").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                let updatedFile = convert(ysFile: file)
                
                ref.child("files/\(file.fileDriveIdentifier)").updateChildValues(updatedFile)
                return FIRTransactionResult.abort()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5)
            {
                ref.child("files/\(file.fileDriveIdentifier)").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                    return FIRTransactionResult.success(withValue: currentData)
                })
                    
            }
        }
    }
    
    static func referenceForCurrentUser() -> FIRDatabaseReference?
    {
        if (FIRAuth.auth()?.currentUser) != nil, let uud = FIRAuth.auth()?.currentUser?.uid
        {
            let ref = FIRDatabase.database().reference(withPath: "users/\(uud)")
            return ref
        }
        return nil
    }
    
    static func callCompletionHandler(_ completionHandler: DriveCompletionHandler?, files : [YSDriveFileProtocol], _ error: YSError)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + completionBlockDelay)
        {
            completionHandler!(files, error)
        }
    }
}
