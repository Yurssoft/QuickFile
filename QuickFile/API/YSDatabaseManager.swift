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

class YSDatabaseManager
{
    //Here usage of transactions in for that reason that when we offline we need to use quries that are no returning all data from db
    
    class func save(pageToken: String, remoteFilesDict: [String : Any],_ folder : YSFolder, _ completionHandler: @escaping AllFilesCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").observeSingleEvent(of: .value, with:
            { (dbFilesData) in
                var dbFilesArrayDict = [String : [String: Any]]()
                if let allDatabaseFilesArrayDict = dbFilesData.value as? [String : [String: Any]]
                {
                    dbFilesArrayDict = allDatabaseFilesArrayDict
                }
                let rootFolderID = YSFolder.rootFolder().folderID
                var ysFiles : [YSDriveFileProtocol] = []
                let nextPageToken = remoteFilesDict["nextPageToken"] as? String
                let remoteFilesArrayDict = remoteFilesDict["files"] as! [[String: Any]]
                
                var isRootFolderAdded = false
                var isSearchFolderAdded = false

                var remoteFilesDict = [String : [String: Any]]()
                for var remoteFile in remoteFilesArrayDict
                {
                    //map ysfiledict to remote property names
                    let fileIdentifier = remoteFile["id"] as! String
                    var emptyFile = [String : Any]()
                    let mappedFile = mapFiles(dbFile: &emptyFile, remoteFile: remoteFile, folder: folder)
                    remoteFilesDict[fileIdentifier] = mappedFile
                }
                
                for var dbFile in dbFilesArrayDict
                {
                    let currentFileIdentifier = dbFile.value["fileDriveIdentifier"] as! String
                    let isRootFolder = (currentFileIdentifier == YSFolder.rootFolder().folderID)
                    if isRootFolder
                    {
                        isRootFolderAdded = isRootFolder
                        continue
                    }
                    let isSearchFolder = (currentFileIdentifier == YSFolder.searchFolder().folderID)
                    if isSearchFolder
                    {
                        isSearchFolderAdded = isSearchFolder
                        continue
                    }
                    if let remoteFile = remoteFilesDict[currentFileIdentifier]
                    {
                        dbFile.value = mergeFiles(dbFile: &dbFile.value, remoteFile: remoteFile, folder: folder)
                        dbFile.value["pageToken"] = pageToken
                        var ysFile = dbFile.value.toYSFile()
                        checkIfFileExists(file: &ysFile)
                        
                        ysFiles.append(ysFile)
                        remoteFilesDict[currentFileIdentifier] = nil
                    }
                    else
                    {
                        if let dbFileFolder = dbFile.value["folder"] as? [String : String?],
                            let dbFileFolderIdentifier = dbFileFolder["folderID"],
                            dbFileFolderIdentifier == folder.folderID
                        {
                            dbFile.value["isDeletedFromDrive"] = true
                        }
                    }
                    dbFilesArrayDict[currentFileIdentifier] = dbFile.value
                }
                
                for var remoteFile in remoteFilesDict
                {
                    remoteFile.value["pageToken"] = pageToken
                    let ysFile = remoteFile.value.toYSFile()
                    remoteFile.value["isAudio"] = ysFile.isAudio
                    ysFiles.append(ysFile)
                    dbFilesArrayDict[(remoteFile.value["fileDriveIdentifier"] as! String)] = remoteFile.value
                }
                
                if !isRootFolderAdded && folder.folderID == rootFolderID
                {
                    let rootFolder = YSDriveFile.init(fileName: YSFolder.rootFolder().folderName, fileSize: "", mimeType: "application/vnd.google-apps.folder", fileDriveIdentifier: YSFolder.rootFolder().folderID, folderName: "", folderID: "", playedTime :"", isPlayed : false, isCurrentlyPlaying : false, isDeletedFromDrive : false, pageToken : "")
                    ysFiles.append(rootFolder)
                    let rootFolderDict = toDictionary(type: rootFolder)
                    dbFilesArrayDict[rootFolder.fileDriveIdentifier] = rootFolderDict
                }
                if !isSearchFolderAdded
                {
                    let searchFolder = YSDriveFile.init(fileName: YSFolder.searchFolder().folderName, fileSize: "", mimeType: "application/vnd.google-apps.folder", fileDriveIdentifier: YSFolder.searchFolder().folderID, folderName: "", folderID: "", playedTime :"", isPlayed : false, isCurrentlyPlaying : false, isDeletedFromDrive : false, pageToken : "")
                    ysFiles.append(searchFolder)
                    let rootFolderDict = toDictionary(type: searchFolder)
                    dbFilesArrayDict[searchFolder.fileDriveIdentifier] = rootFolderDict
                }
                ref.child("files").setValue(dbFilesArrayDict)
                ysFiles = ysFiles.filter({ (ysFile) -> Bool in
                    return ysFile.folder.folderID == folder.folderID
                })
                ysFiles = sort(ysFiles: ysFiles)
                
                callCompletionHandler(nextPageToken: nextPageToken, completionHandler, files: ysFiles, YSError())
            })
        }
        else
        {
            callCompletionHandler(nextPageToken: nil, completionHandler, files: [], notLoggedInError() as! YSError)
        }
    }
    
    fileprivate class func checkIfFileExists(file: inout YSDriveFileProtocol)
    {
        if !YSAppDelegate.appDelegate().filesOnDisk.contains(file.fileDriveIdentifier) && file.localFileExists()
        {
            YSAppDelegate.appDelegate().filesOnDisk.insert(file.fileDriveIdentifier)
            var file = file
            _ = file.updateFileSize()
        }
    }
    
    fileprivate class func mapFiles(dbFile: inout [String: Any], remoteFile:[String: Any], folder : YSFolder) -> [String: Any]
    {
        var dbFile = dbFile
        dbFile["fileDriveIdentifier"] = remoteFile["id"]
        dbFile["folder"] = toDictionary(type: folder)
        dbFile["fileName"] = remoteFile["name"]
        dbFile["mimeType"] = remoteFile["mimeType"]
        dbFile["fileSize"] = remoteFile["size"]
        dbFile["isDeletedFromDrive"] = false
        return dbFile
    }
    
    fileprivate class func mergeFiles(dbFile: inout [String: Any], remoteFile:[String: Any], folder : YSFolder) -> [String: Any]
    {
        var dbFile = dbFile
        dbFile["fileDriveIdentifier"] = remoteFile["fileDriveIdentifier"]
        dbFile["folder"] = toDictionary(type: folder)
        dbFile["fileName"] = remoteFile["fileName"]
        dbFile["mimeType"] = remoteFile["mimeType"]
        dbFile["fileSize"] = remoteFile["fileSize"]
        dbFile["isDeletedFromDrive"] = false
        return dbFile
    }
    
    class func offlineFiles(folder: YSFolder,_ error: YSError,_ completionHandler: @escaping AllFilesCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").observeSingleEvent(of: .value, with:
            { (dbFiles) in
                var sortedFiles : [YSDriveFileProtocol] = []
                var files = [YSDriveFileProtocol]()
                for currentDatabaseFile in dbFiles.children
                {
                    let databaseFile = currentDatabaseFile as! DataSnapshot
                    let dbFile = databaseFile.value as! [String : Any]
                    var ysFile = dbFile.toYSFile()
                    if ysFile.folder.folderID == folder.folderID
                    {
                        files.append(ysFile)
                    }
                }
                sortedFiles = sort(ysFiles: files)
                callCompletionHandler(nextPageToken: nil, completionHandler, files: sortedFiles, error)
            })
        }
        else
        {
            callCompletionHandler(nextPageToken: nil, completionHandler, files: [], error)
        }
    }
    
    class func getAllFiles(_ completionHandler: @escaping AllFilesCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").observeSingleEvent(of: .value, with:
            { (dbFiles) in
                var sortedFiles : [YSDriveFileProtocol] = []
                if dbFiles.hasChildren()
                {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in dbFiles.children
                    {
                        let databaseFile = currentDatabaseFile as! DataSnapshot
                        let dbFile = databaseFile.value as! [String : Any]
                        let ysFile = dbFile.toYSFile()
                        files.append(ysFile)
                    }
                    sortedFiles = sort(ysFiles: files)
                }
                callCompletionHandler(nextPageToken: nil, completionHandler, files: sortedFiles, YSError())
            })
        }
        else
        {
            callCompletionHandler(nextPageToken: nil, completionHandler, files: [], notLoggedInError() as! YSError)
        }
    }
    
    class func deleteAllDownloads(_ completionHandler: @escaping ErrorCompletionHandler)
    {
        let documentsUrls = getAllFilesUrls()
        _ = documentsUrls.map
        { url in
            try? FileManager.default.removeItem(at: url)
            //TODO: remove download by file identifier
            //YSAppDelegate.appDelegate().fileDownloader.cancelDownloading(file identifier: file identifier)
        }
        YSAppDelegate.appDelegate().filesOnDisk.removeAll()
        
        let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "All local downloads deleted", buttonTitle: "GOT IT")
        callCompletionHandler(completionHandler, error)
    }
    
    private class func getAllFilesUrls() -> [URL]
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = (try? FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])) ?? []
        let allUrls = directoryContents.filter{ $0.pathExtension == "mp3" }
        return allUrls
    }
    
    class func getAllFileNamesOnDisk() -> Set<String>
    {
        let allFilesInDocumentsFolder = getAllFilesUrls()
        let mp3FileNames = allFilesInDocumentsFolder.map{ $0.deletingPathExtension().lastPathComponent }
        let allFileNames = Set<String>().union(mp3FileNames)
        return allFileNames
    }
    
    class func deletePlayedDownloads(_ completionHandler: @escaping ErrorCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").observeSingleEvent(of: .value, with:
            { (dbFilesData) in
                for currentDatabaseFile in dbFilesData.children
                {
                    let databaseFile = currentDatabaseFile as! DataSnapshot
                    let dbFile = databaseFile.value as! [String : Any]
                    let ysFile = dbFile.toYSFile()
                    if ysFile.isPlayed
                    {
                        ysFile.removeLocalFile()
                        YSAppDelegate.appDelegate().fileDownloader.cancelDownloading(file: ysFile)
                    }
                }
                let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "Played local downloads deleted", buttonTitle: "GOT IT")
                callCompletionHandler(completionHandler, error)
            })
        }
        else
        {
            callCompletionHandler(completionHandler, notLoggedInError() as! YSError)
        }
    }
    
    class func deleteDatabase(_ completionHandler: @escaping ErrorCompletionHandler)
    {
        deleteAllDownloads({ _ in })
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").removeValue()
            let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "Database deleted", buttonTitle: "GOT IT")
            callCompletionHandler(completionHandler, error)
        }
        else
        {
            callCompletionHandler(completionHandler, notLoggedInError() as! YSError)
        }
    }
    
    class func allFilesWithCurrentPlaying(completionHandler: @escaping AllFilesAndCurrentPlayingCompletionHandler)
    {
        if let ref = referenceForCurrentUser()
        {
            ref.child("files").observeSingleEvent(of: .value, with:
            { (dbFilesData) in
                var sortedFiles : [YSDriveFileProtocol] = []
                var currentPlayingFile : YSDriveFileProtocol? = nil
                var files = [YSDriveFileProtocol]()
                for currentDatabaseFile in dbFilesData.children
                {
                    let databaseFile = currentDatabaseFile as! DataSnapshot
                    let dbFile = databaseFile.value as! [String : Any]
                    let ysFile = dbFile.toYSFile()
                    if ysFile.isCurrentlyPlaying && ysFile.localFileExists()
                    {
                        currentPlayingFile = ysFile
                    }
                    files.append(ysFile)
                }
                sortedFiles = sort(ysFiles: files)
                completionHandler(sortedFiles, currentPlayingFile, nil)
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
    
    class func updatePlayingInfo(file: YSDriveFileProtocol)
    {
        if let ref = referenceForCurrentUser()
        {
            let identifier = file.fileDriveIdentifier
            ref.child("files/\(identifier)").observeSingleEvent(of: .value, with:
            { (dbFilesData) in
                if var dbFile = dbFilesData.value as? [String : Any], let currentFileIdentifier = dbFile["fileDriveIdentifier"] as? String, currentFileIdentifier == identifier
                {
                    dbFile["isCurrentlyPlaying"] = file.isCurrentlyPlaying
                    dbFile["playedTime"] = file.playedTime
                    dbFile["isPlayed"] = file.isPlayed
                    ref.child("files/\(identifier)").setValue(dbFile)
                }
            })
        }
    }
    
    class func updateGenaralFileInfo(file: YSDriveFileProtocol)
    {
        if let ref = referenceForCurrentUser()
        {
            let identifier = file.fileDriveIdentifier
            ref.child("files/\(identifier)").observeSingleEvent(of: .value, with:
            { (dbFilesData) in
                var file = file
                file.folder = YSFolder.searchFolder()
                var updatedFile = toDictionary(type: file)
                
                for currentDatabaseFile in dbFilesData.children
                {
                    let databaseFile = currentDatabaseFile as! DataSnapshot
                    if var dbFile = databaseFile.value as? [String : Any], let folderDict = dbFile["folder"] as? [String : String], let folderName = folderDict["folderName"], let folderID = folderDict["folderID"]
                    {
                        let folder = YSFolder()
                        folder.folderName = folderName
                        folder.folderID = folderID
                        updatedFile = mergeFiles(dbFile: &dbFile, remoteFile: updatedFile, folder: folder)
                    }
                    else
                    {
                        let log = SwiftyBeaver.self
                        log.error("Something wrong with dbFile : \(databaseFile)")
                    }
                }
                ref.child("files/\(file.fileDriveIdentifier)").setValue(updatedFile)
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
    
    private class func referenceForCurrentUser() -> DatabaseReference?
    {
        if (Auth.auth().currentUser) != nil, let uud = Auth.auth().currentUser?.uid
        {
            let ref = Database.database().reference(withPath: "users/\(uud)")
            ref.keepSynced(true)
            return ref
        }
        return nil
    }
    
    private class func callCompletionHandler(nextPageToken: String?, _ completionHandler: AllFilesCompletionHandler?, files : [YSDriveFileProtocol], _ error: YSError)
    {
        DispatchQueue.main.async
        {
            completionHandler!(files, error, nextPageToken)
        }
    }
    
    private class func callCompletionHandler(_ completionHandler: ErrorCompletionHandler?, _ error: YSError)
    {
        DispatchQueue.main.async
        {
            completionHandler!(error)
        }
    }
}
