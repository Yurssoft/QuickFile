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
    
    class func save(filesDictionary: [String : Any],_ folder : String, _ completionHandler: DriveCompletionHandler? = nil)
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
                let filesDictArray = filesDictionary["files"] as! [[String: Any]]
                for fileDict in filesDictArray
                {
                    let ysFile = YSDriveFile.init(fileName: fileDict["name"] as! String?,
                                                  fileSize: fileDict["mimeType"] as! String?,
                                                  mimeType: fileDict["mimeType"] as! String?,
                                                  fileDriveIdentifier: fileDict["id"] as! String?)
                    
                    ysFile.isFileOnDisk = ysFile.localFileExists()
                    ysfiles.append(ysFile)
                    dbFilesDict[ysFile.fileDriveIdentifier] = ysFile.toDictionary()
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

    class func getFiles(folderID: String,_ error: YSError,_ completionHandler: DriveCompletionHandler? = nil)
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
                        var ysFile = dbFile.toYSFile()
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
    
    class func update(file: YSDriveFileProtocol)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files/\(file.fileDriveIdentifier)").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                let updatedFile = (file as! YSDriveFile).toDictionary()
                
                ref.child("files/\(file.fileDriveIdentifier)").updateChildValues(updatedFile)
                return FIRTransactionResult.abort()
            })
        }
    }
    
    private class func sortFiles(ysFiles: [YSDriveFileProtocol]) -> [YSDriveFileProtocol]
    {
        let sortedFiles = ysFiles.sorted(by: { (_ file1,_ file2) -> Bool in
            return file1.isAudio == file2.isAudio ? file1.fileName < file2.fileName : !file1.isAudio
        })
        return sortedFiles
    }
    
    private class func databaseFilesDictionary(from databaseFiles: FIRMutableData) -> [String : [String: Any]]
    {
        var databaseFilesDictionary = [String : [String: Any]]()
        for currentDatabaseFile in databaseFiles.children
        {
            let databaseFile = currentDatabaseFile as! FIRMutableData
            let dbFile = databaseFile.value as! [String : Any]
            if let fileDriveIdentifier = dbFile["fileDriveIdentifier"] as? String
            {
                databaseFilesDictionary[fileDriveIdentifier] = dbFile
            }
            else
            {
                print("Something wrong with dbFile : \(dbFile)")
            }
        }
        return databaseFilesDictionary
    }
    
    
    private class func referenceForCurrentUser() -> FIRDatabaseReference?
    {
        if (FIRAuth.auth()?.currentUser) != nil, let uud = FIRAuth.auth()?.currentUser?.uid
        {
            let ref = FIRDatabase.database().reference(withPath: "users/\(uud)")
            return ref
        }
        return nil
    }
    
    private class func callCompletionHandler(_ completionHandler: DriveCompletionHandler?, files : [YSDriveFileProtocol], _ error: YSError)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + completionBlockDelay)
        {
            completionHandler!(files, error)
        }
    }
}
