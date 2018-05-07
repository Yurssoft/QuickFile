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

class YSDatabaseManager {
    class func save(pageToken: String, remoteFiles: YSFiles, _ folder: YSFolder, _ completionHandler: @escaping AllFilesCH) {
        if let ref = referenceForCurrentUser() {
            ref.child("files").observeSingleEvent(of: .value, with: { (dbFilesData) in
                var dbFilesArrayDict = [String: [String: Any]]()
                if let allDatabaseFilesArrayDict = dbFilesData.value as? [String: [String: Any]] {
                    dbFilesArrayDict = allDatabaseFilesArrayDict
                }
                let rootFolderID = YSFolder.rootFolder().folderID
                var ysFiles: [YSDriveFileProtocol] = []
                let nextPageToken = remoteFiles.nextPageToken
                let remoteFilesArray = remoteFiles.files

                var isRootFolderAdded = false
                var isSearchFolderAdded = false

                var remoteFilesDict = [String: YSDriveFile]()
                for remoteFile in remoteFilesArray {
                    let fileIdentifier = remoteFile.id
                    remoteFilesDict[fileIdentifier] = remoteFile
                }

                for var dbFile in dbFilesArrayDict {
                    dbFile.value.migrateDict()
                    let currentFileIdentifier = dbFile.value[forKey: "id", ""]
                    let isRootFolder = (currentFileIdentifier == YSFolder.rootFolder().folderID)
                    if isRootFolder {
                        isRootFolderAdded = isRootFolder
                        continue
                    }
                    let isSearchFolder = (currentFileIdentifier == YSFolder.searchFolder().folderID)
                    if isSearchFolder {
                        isSearchFolderAdded = isSearchFolder
                        continue
                    }
                    if let remoteFile = remoteFilesDict[currentFileIdentifier] {
                        dbFile.value = mergeFiles(dbFile: &dbFile.value, remoteFile: remoteFile, folder: folder)
                        dbFile.value["pageToken"] = pageToken
                        let ysFile = dbFile.value.toYSFile()
                        ysFiles.append(ysFile)
                        remoteFilesDict[currentFileIdentifier] = nil
                    } else {
                        if let dbFileFolder = dbFile.value["folder"] as? [String: String?],
                            let dbFileFolderIdentifier = dbFileFolder["folderID"],
                            dbFileFolderIdentifier == folder.folderID {
                            dbFile.value["isDeletedFromDrive"] = true
                        }
                    }
                    dbFilesArrayDict[currentFileIdentifier] = dbFile.value
                }
                for var remoteFile in remoteFilesDict.values {
                    remoteFile.pageToken = pageToken
                    remoteFile.folder = folder
                    ysFiles.append(remoteFile)
                    dbFilesArrayDict[remoteFile.id] = remoteFile.toDictionary()
                }

                if !isRootFolderAdded && folder.folderID == rootFolderID {
                    let rootFolder = YSDriveFile.init(name: YSFolder.rootFolder().folderName, size: "", mimeType: "application/vnd.google-apps.folder", id: YSFolder.rootFolder().folderID, folderName: "", folderID: "", playedTime: "", isPlayed: false, isCurrentlyPlaying: false, isDeletedFromDrive: false, pageToken: "")
                    ysFiles.append(rootFolder)
                    let rootFolderDict = rootFolder.toDictionary()
                    dbFilesArrayDict[rootFolder.id] = rootFolderDict
                }
                if !isSearchFolderAdded {
                    let searchFolder = YSDriveFile.init(name: YSFolder.searchFolder().folderName, size: "", mimeType: "application/vnd.google-apps.folder", id: YSFolder.searchFolder().folderID, folderName: "", folderID: "", playedTime: "", isPlayed: false, isCurrentlyPlaying: false, isDeletedFromDrive: false, pageToken: "")
                    ysFiles.append(searchFolder)
                    let rootFolderDict = searchFolder.toDictionary()
                    dbFilesArrayDict[searchFolder.id] = rootFolderDict
                }
                ref.child("files").setValue(dbFilesArrayDict)
                ysFiles = ysFiles.filter({ (ysFile) -> Bool in
                    return ysFile.folder.folderID == folder.folderID
                })
                ysFiles = sort(ysFiles: ysFiles)

                callCompletionHandler(nextPageToken: nextPageToken, completionHandler, files: ysFiles, YSError())
            })
        } else {
            callCompletionHandler(nextPageToken: nil, completionHandler, files: [], notLoggedInError())
        }
    }

    fileprivate class func mergeFiles(dbFile: inout [String: Any], remoteFile: YSDriveFile, folder: YSFolder) -> [String: Any] {
        var dbFile = dbFile
        dbFile["id"] = remoteFile.id
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(folder)
        dbFile["folder"] = YSNetworkResponseManager.convertToDictionary(from: data)
        dbFile["name"] = remoteFile.name
        dbFile["mimeType"] = remoteFile.mimeType
        dbFile["size"] = remoteFile.size
        dbFile["isDeletedFromDrive"] = false
        return dbFile
    }

    class func offlineFiles(id: String, _ error: YSError, _ completionHandler: @escaping AllFilesCH) {
        if let ref = referenceForCurrentUser() {
            ref.child("files").observeSingleEvent(of: .value, with: { (dbFiles) in
                var sortedFiles: [YSDriveFileProtocol] = []
                var files = [YSDriveFileProtocol]()
                for currentDatabaseFile in dbFiles.children {
                    if let databaseFile = currentDatabaseFile as? DataSnapshot,
                        var dbFile = databaseFile.value as? [String: Any] {
                        var ysFile = dbFile.toYSFile()
                        if ysFile.folder.folderID == id {
                            files.append(ysFile)
                        }
                    }
                }
                sortedFiles = sort(ysFiles: files)
                callCompletionHandler(nextPageToken: nil, completionHandler, files: sortedFiles, error)
            })
        } else {
            callCompletionHandler(nextPageToken: nil, completionHandler, files: [], error)
        }
    }

    class func getAllFiles(_ completionHandler: @escaping AllFilesCH) {
        if let ref = referenceForCurrentUser() {
            ref.child("files").observeSingleEvent(of: .value, with: { (dbFiles) in
                var sortedFiles: [YSDriveFileProtocol] = []
                if dbFiles.hasChildren() {
                    var files = [YSDriveFileProtocol]()
                    for currentDatabaseFile in dbFiles.children {
                        if let databaseFile = currentDatabaseFile as? DataSnapshot,
                            var dbFile = databaseFile.value as? [String: Any] {
                            let ysFile = dbFile.toYSFile()
                            files.append(ysFile)
                        }
                    }
                    sortedFiles = sort(ysFiles: files)
                }
                callCompletionHandler(nextPageToken: nil, completionHandler, files: sortedFiles, YSError())
            })
        } else {
            callCompletionHandler(nextPageToken: nil, completionHandler, files: [], notLoggedInError())
        }
    }

    class func deleteAllDownloads(_ completionHandler: @escaping ErrorCH) {
        let documentsUrls = getAllFilesUrls()
        _ = documentsUrls.map { url in
            try? FileManager.default.removeItem(at: url)
        }
        YSAppDelegate.appDelegate().fileDownloader.cancelAllDownloads()
        YSAppDelegate.appDelegate().filesOnDisk.removeAll()

        let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "All local downloads deleted", buttonTitle: "GOT IT")
        callCompletionHandler(completionHandler, error)
    }

    private class func getAllFilesUrls() -> [URL] {
        var allUrls = [URL]()
        guard let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let directoryContents = try? FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: []) else { return allUrls }
        allUrls = directoryContents.filter { $0.pathExtension == "mp3" }
        return allUrls
    }

    class func getAllnamesOnDisk() -> Set<String> {
        let allFilesInDocumentsFolder = getAllFilesUrls()
        let mp3names = allFilesInDocumentsFolder.map { $0.deletingPathExtension().lastPathComponent }
        let allnames = Set<String>().union(mp3names)
        return allnames
    }

    class func deletePlayedDownloads(_ completionHandler: @escaping ErrorCH) {
        if let ref = referenceForCurrentUser() {
            ref.child("files").observeSingleEvent(of: .value, with: { (dbFilesData) in
                for currentDatabaseFile in dbFilesData.children {
                    if let databaseFile = currentDatabaseFile as? DataSnapshot,
                        var dbFile = databaseFile.value as? [String: Any] {
                        let ysFile = dbFile.toYSFile()
                        if ysFile.isPlayed {
                            ysFile.removeLocalFile()
                            YSAppDelegate.appDelegate().fileDownloader.cancelDownloading(id: ysFile.id)
                        }
                    }
                }
                let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "Played local downloads deleted", buttonTitle: "GOT IT")
                callCompletionHandler(completionHandler, error)
            })
        } else {
            callCompletionHandler(completionHandler, notLoggedInError())
        }
    }

    class func deleteDatabase(_ completionHandler: @escaping ErrorCH) {
        deleteAllDownloads({ _ in })
        if let ref = referenceForCurrentUser() {
            ref.child("files").removeValue()
            let error = YSError(errorType: YSErrorType.none, messageType: Theme.success, title: "Deleted", message: "Database deleted", buttonTitle: "GOT IT")
            callCompletionHandler(completionHandler, error)
        } else {
            callCompletionHandler(completionHandler, notLoggedInError())
        }
    }

    class func allFilesWithCurrentPlaying(completionHandler: @escaping AllFilesAndCurrentPlayingCH) {
        if let ref = referenceForCurrentUser() {
            ref.child("files").observeSingleEvent(of: .value, with: { (dbFilesData) in
                var sortedFiles: [YSDriveFileProtocol] = []
                var currentPlayingFile: YSDriveFileProtocol? = nil
                var files = [YSDriveFileProtocol]()
                for currentDatabaseFile in dbFilesData.children {
                    if let databaseFile = currentDatabaseFile as? DataSnapshot,
                        var dbFile = databaseFile.value as? [String: Any] {
                        let ysFile = dbFile.toYSFile()
                        if ysFile.isCurrentlyPlaying && ysFile.localFileExists() {
                            currentPlayingFile = ysFile
                        }
                        files.append(ysFile)
                    }
                }
                sortedFiles = sort(ysFiles: files)
                completionHandler(sortedFiles, currentPlayingFile, nil)
            })
        } else {
            completionHandler([], nil, notLoggedInError())
        }
    }

    private class func notLoggedInError() -> YSError {
        let error = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.warning, title: "Not logged in", message: "Not logged in to drive", buttonTitle: "Login")
        return error
    }

    class func updatePlayingInfo(file: YSDriveFileProtocol) {
        if let ref = referenceForCurrentUser() {
            let identifier = file.id
            ref.child("files/\(identifier)").observeSingleEvent(of: .value, with: { (dbFilesData) in
                if var dbFile = dbFilesData.value as? [String: Any], let currentFileIdentifier = dbFile["id"] as? String, currentFileIdentifier == identifier {
                    dbFile["isCurrentlyPlaying"] = file.isCurrentlyPlaying
                    dbFile["playedTime"] = file.playedTime
                    dbFile["isPlayed"] = file.isPlayed
                    ref.child("files/\(identifier)").setValue(dbFile)
                }
            })
        }
    }

    class func updateGenaralFileInfo(file: YSDriveFileProtocol) {
        if let ref = referenceForCurrentUser() {
            let identifier = file.id
            ref.child("files/\(identifier)").observeSingleEvent(of: .value, with: { (dbFilesData) in
                var file = file
                file.folder = YSFolder.searchFolder()
                var updatedFile = file.toDictionary()

                for currentDatabaseFile in dbFilesData.children {
                    if let databaseFile = currentDatabaseFile as? DataSnapshot,
                        var dbFile = databaseFile.value as? [String: Any],
                        let folderDict = dbFile["folder"] as? [String: String],
                        let folderName = folderDict["folderName"],
                        let folderID = folderDict["folderID"],
                        let file = file as? YSDriveFile {
                        var folder = YSFolder()
                        folder.folderName = folderName
                        folder.folderID = folderID
                        updatedFile = mergeFiles(dbFile: &dbFile, remoteFile: file, folder: folder)
                    } else {
                        logDefault(.DB, .Error, "Something wrong with dbFile : \(currentDatabaseFile as? DataSnapshot)")
                    }
                }
                ref.child("files/\(file.id)").setValue(updatedFile)
            })
        }
    }

    private class func sort(ysFiles: [YSDriveFileProtocol]) -> [YSDriveFileProtocol] {
        let sortedFiles = ysFiles.sorted { file1, file2 in
            return file1.isAudio == file2.isAudio ? file1.name < file2.name : !file1.isAudio
        }
        return sortedFiles
    }

    private class func referenceForCurrentUser() -> DatabaseReference? {
        if (Auth.auth().currentUser) != nil, let uud = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference(withPath: "users/\(uud)")
            ref.keepSynced(true)
            return ref
        }
        return nil
    }

    private class func callCompletionHandler(nextPageToken: String?, _ completionHandler: AllFilesCH?, files: [YSDriveFileProtocol], _ error: YSError) {
        DispatchQueue.main.async {
            completionHandler!(files, error, nextPageToken)
        }
    }

    private class func callCompletionHandler(_ completionHandler: ErrorCH?, _ error: YSError) {
        DispatchQueue.main.async {
            completionHandler!(error)
        }
    }
}
