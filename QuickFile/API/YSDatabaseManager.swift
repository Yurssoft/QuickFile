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
import SwiftyBeaver

typealias AllFilesCompletionHandler = ([YSDriveFileProtocol],YSErrorProtocol?) -> Swift.Void
typealias AllFilesAndCurrentPlayingCompletionHandler = ([YSDriveFileProtocol], YSDriveFileProtocol?,YSErrorProtocol?) -> Swift.Void

class YSDatabaseManager
{
    private static let completionBlockDelay = 0.3
    
    class func save(filesDictionary: [String : Any],_ folder : YSFolder, _ completionHandler: @escaping AllFilesCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: MutableData) -> TransactionResult in
                
                var dbFilesDict = databaseFilesDictionary(from: dbFiles)
                var dbFilesForFolderToBeDeleted = [String : [String: Any]]()
                var isRootFolderAdded = false
                for key in dbFilesDict.keys
                {
                    var dbFile = dbFilesDict[key]
                    if let ID = dbFile?["fileDriveIdentifier"] as! String?, ID == "root"
                    {
                        isRootFolderAdded = true
                    }
                    let folderObj = dbFile?["folder"] as! [String: String]
                    let dbFileFolderID = folderObj["folderID"]
                    if dbFileFolderID == folder.folderID
                    {
                        dbFilesForFolderToBeDeleted[key] = dbFile
                        dbFilesDict[key] = nil
                    }
                }
                if !isRootFolderAdded
                {
                    let rootFolder = YSDriveFile.init(fileName: "Root", fileSize: "", mimeType: "application/vnd.google-apps.folder", fileDriveIdentifier: YSFolder.rootFolder().folderID, folderName: "", folderID: "", playedTime :"", isPlayed : false, isCurrentlyPlaying : false)
                    dbFilesDict[rootFolder.fileDriveIdentifier] = toDictionary(type: rootFolder)
                }
                var ysfiles : [YSDriveFileProtocol] = []
                let filesDictArray = filesDictionary["files"] as! [[String: Any]]
                for fileDict in filesDictArray
                {
                    var playedTime = ""
                    var isPlayed = false
                    var isCurrentlyPlaying = false
                    if let id = fileDict["name"] as! String?, let dbFile = dbFilesForFolderToBeDeleted[id]
                    {
                        let dbysFile = dbFile.toYSFile()
                        playedTime = dbysFile.playedTime
                        isCurrentlyPlaying = dbysFile.isCurrentlyPlaying
                        isPlayed = dbysFile.isPlayed
                    }
                    let ysFile = YSDriveFile.init(fileName: fileDict["name"] as! String?,
                                                  fileSize: fileDict["size"] as! String?,
                                                  mimeType: fileDict["mimeType"] as! String?,
                                                  fileDriveIdentifier: fileDict["id"] as! String?,
                                                  folderName: folder.folderName,
                                                  folderID: folder.folderID,
                                                  playedTime : playedTime,
                                                  isPlayed : isPlayed,
                                                  isCurrentlyPlaying : isCurrentlyPlaying)
                    
                    ysfiles.append(ysFile)
                    dbFilesForFolderToBeDeleted[ysFile.fileDriveIdentifier] = nil
                    dbFilesDict[ysFile.fileDriveIdentifier] = toDictionary(type: ysFile)
                }
                
                for key in dbFilesForFolderToBeDeleted.keys
                {
                    var dbFileToBeDeleted = dbFilesForFolderToBeDeleted[key]
                    let ysFile = dbFileToBeDeleted?.toYSFile()
                    ysFile?.removeLocalFile()
                    dbFileToBeDeleted?[key] = nil
                }

                ref.child("files").setValue(dbFilesDict)

                completionHandler(sort(ysFiles: ysfiles), YSError())
                
                return TransactionResult.abort()
            })
        }
        else
        {
            completionHandler([], notLoggedInError())
        }
    }

    class func files(for folder: YSFolder,_ error: YSError,_ completionHandler: @escaping AllFilesCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: MutableData) -> TransactionResult in
                var sortedFiles : [YSDriveFileProtocol] = []
                if dbFiles.hasChildren()
                {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in dbFiles.children
                    {
                        let databaseFile = currentDatabaseFile as! MutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        var ysFile = dbFile.toYSFile()
                        if ysFile.folder.folderID == folder.folderID
                        {
                            files.append(ysFile)
                        }
                    }
                    sortedFiles = sort(ysFiles: files)
                }
                callCompletionHandler(completionHandler, files: sortedFiles, error)
                return TransactionResult.abort()
            })
        }
        else
        {
            callCompletionHandler(completionHandler, files: [], error)
        }
    }
    
    class func deleteAllDownloads(_ completionHandler: @escaping CompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: MutableData) -> TransactionResult in
                if dbFiles.hasChildren()
                {
                    for currentDatabaseFile in dbFiles.children
                    {
                        let databaseFile = currentDatabaseFile as! MutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        let ysFile = dbFile.toYSFile()
                        ysFile.removeLocalFile()
                        YSAppDelegate.appDelegate().fileDownloader?.cancelDownloading(file: ysFile)
                    }
                }
                let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "All local downloads deleted", buttonTitle: "GOT IT")
                completionHandler(error)
                return TransactionResult.abort()
            })
        }
        else
        {
            completionHandler(notLoggedInError())
        }
    }
    
    class func deletePlayedDownloads(_ completionHandler: @escaping CompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: MutableData) -> TransactionResult in
                if dbFiles.hasChildren()
                {
                    for currentDatabaseFile in dbFiles.children
                    {
                        let databaseFile = currentDatabaseFile as! MutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        let ysFile = dbFile.toYSFile()
                        if (ysFile.isPlayed)
                        {
                            ysFile.removeLocalFile()
                            YSAppDelegate.appDelegate().fileDownloader?.cancelDownloading(file: ysFile)
                        }
                    }
                }
                let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "Played local downloads deleted", buttonTitle: "GOT IT")
                completionHandler(error)
                return TransactionResult.abort()
            })
        }
        else
        {
            completionHandler(notLoggedInError())
        }
    }
    
    class func deleteDatabase(_ completionHandler: @escaping CompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: MutableData) -> TransactionResult in
                ref.child("files").setValue([:])
                let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "Database deleted", buttonTitle: "GOT IT")
                completionHandler(error)
                return TransactionResult.abort()
            })
        }
        else
        {
            completionHandler(notLoggedInError())
        }
    }
    
    class func allFilesWithCurrentPlaying(completionHandler: @escaping AllFilesAndCurrentPlayingCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").runTransactionBlock({ (dbFiles: MutableData) -> TransactionResult in
                var sortedFiles : [YSDriveFileProtocol] = []
                var currentPlayingFile : YSDriveFileProtocol? = nil
                if dbFiles.hasChildren()
                {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in dbFiles.children
                    {
                        let databaseFile = currentDatabaseFile as! MutableData
                        let dbFile = databaseFile.value as! [String : Any]
                        let ysFile = dbFile.toYSFile()
                        if ysFile.isCurrentlyPlaying && ysFile.localFileExists()
                        {
                            currentPlayingFile = ysFile
                        }
                        files.append(ysFile)
                    }
                    sortedFiles = sort(ysFiles: files)
                }
                completionHandler(sortedFiles, currentPlayingFile, nil)
                return TransactionResult.abort()
            })
        }
        else
        {
            completionHandler([], nil, notLoggedInError())
        }
    }
    
    private class func notLoggedInError() -> YSErrorProtocol
    {
        let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
        return error
    }
    
    class func update(file: YSDriveFileProtocol)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files/\(file.fileDriveIdentifier)").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                let updatedFile = toDictionary(type: file)
                ref.child("files/\(file.fileDriveIdentifier)").updateChildValues(updatedFile)
                return TransactionResult.abort()
            })
        }
    }
    
    private class func sort(ysFiles: [YSDriveFileProtocol]) -> [YSDriveFileProtocol]
    {
        let sortedFiles = ysFiles.sorted(by: { (_ file1,_ file2) -> Bool in
            return file1.isAudio == file2.isAudio ? file1.fileName < file2.fileName : !file1.isAudio
        })
        return sortedFiles
    }
    
    private class func databaseFilesDictionary(from databaseFiles: MutableData) -> [String : [String: Any]]
    {
        var databaseFilesDictionary = [String : [String: Any]]()
        for currentDatabaseFile in databaseFiles.children
        {
            let databaseFile = currentDatabaseFile as! MutableData
            let dbFile = databaseFile.value as! [String : Any]
            if let fileDriveIdentifier = dbFile["fileDriveIdentifier"] as? String
            {
                databaseFilesDictionary[fileDriveIdentifier] = dbFile
            }
            else
            {
                let log = SwiftyBeaver.self
                log.error("Something wrong with dbFile : \(dbFile)")
            }
        }
        return databaseFilesDictionary
    }
    
    
    private class func referenceForCurrentUser() -> DatabaseReference?
    {
        if (Auth.auth().currentUser) != nil, let uud = Auth.auth().currentUser?.uid
        {
            let ref = Database.database().reference(withPath: "users/\(uud)")
            return ref
        }
        return nil
    }
    
    private class func callCompletionHandler(_ completionHandler: AllFilesCompletionHandler?, files : [YSDriveFileProtocol], _ error: YSError)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + completionBlockDelay)
        {
            completionHandler!(files, error)
        }
    }
}
