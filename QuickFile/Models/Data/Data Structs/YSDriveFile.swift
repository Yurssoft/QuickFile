//
//  YSDriveFile.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSDriveFile: YSDriveFileProtocol {
    var fileName: String //Book 343
    var fileSize: String //108.03 MB (47 audio) or 10:18
    var mimeType: String
    var pageToken: String
    var isAudio: Bool {
        if !mimeType.isEmpty && (mimeType.contains("mp3") || mimeType.contains("audio") || mimeType.contains("mpeg")) {
            return true
        } else {
            return false
        }
    }
    var fileDriveIdentifier: String
    var modifiedTime: String = ""
    var folder: YSFolder = YSFolder()
    var isDeletedFromDrive: Bool = false

    var playedTime: String
    var isPlayed: Bool
    var isCurrentlyPlaying: Bool

    enum YSDriveFileCodingKeys: String, CodingKey {
        case fileDriveIdentifier = "id"
        case fileName = "name"
        case mimeType
        case fileSize = "size"
    }
    
    enum YSDriveFileEncodingKeys: String, CodingKey {
        case fileDriveIdentifier
        case fileName
        case fileSize
        case folder
        case isAudio
        case isCurrentlyPlaying
        case isDeletedFromDrive
        case isPlayed
        case mimeType
        case pageToken
        case playedTime
    }
    
    init(fileName: String?, fileSize: String?, mimeType: String?, fileDriveIdentifier: String?, folderName: String?, folderID: String?, playedTime: String?, isPlayed: Bool, isCurrentlyPlaying: Bool, isDeletedFromDrive: Bool, pageToken: String?) {
        self.fileName = fileName.unwrapped()
        self.fileSize = fileSize.unwrapped()
        self.mimeType = mimeType.unwrapped()
        self.fileDriveIdentifier = fileDriveIdentifier.unwrapped()
        self.folder.folderName = folderName.unwrapped()
        self.folder.folderID = folderID.unwrapped()

        self.playedTime = playedTime.unwrapped()
        self.isPlayed = isPlayed
        self.isCurrentlyPlaying = isCurrentlyPlaying
        self.isDeletedFromDrive = false
        self.pageToken = pageToken.unwrapped()
    }
    
    init(fileName: String, fileSize: String, mimeType: String, fileDriveIdentifier: String, folderName: String, folderID: String, playedTime: String, isPlayed: Bool, isCurrentlyPlaying: Bool, isDeletedFromDrive: Bool, pageToken: String) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.fileDriveIdentifier = fileDriveIdentifier
        self.folder.folderName = folderName
        self.folder.folderID = folderID
        self.playedTime = playedTime
        self.isPlayed = isPlayed
        self.isCurrentlyPlaying = isCurrentlyPlaying
        self.isDeletedFromDrive = false
        self.pageToken = pageToken
    }

    init() {
        self.fileName = ""
        self.fileSize = ""
        self.mimeType = ""
        self.fileDriveIdentifier = ""
        self.playedTime = ""
        self.isPlayed = false
        self.isCurrentlyPlaying = false
        self.isDeletedFromDrive = false
        self.pageToken = ""
    }

    func localFileExists() -> Bool {
        return YSDriveFile.localFileExistsStatic(fileDriveIdentifier: fileDriveIdentifier)
    }

    static func localFileExistsStatic(fileDriveIdentifier: String) -> Bool {
        return YSAppDelegate.appDelegate().filesOnDisk.contains(fileDriveIdentifier)
    }

    mutating func updateFileSize() -> UInt64 {
        var fileSize: UInt64 = 0
        //TODO: get file size with directory contents on app start
        guard let filePath = localFilePath()?.path else { return fileSize }
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            guard let fileSizeInt = attr[FileAttributeKey.size] as? UInt64 else { return fileSize }
            fileSize = fileSizeInt
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            self.fileSize = String(fileSize)
        } catch let error as NSError {
            logDriveSubdomain(.Model, .Error, "Error creating file path: " + error.localizedDescriptionAndUnderlyingKey)
        }
        return fileSize
    }

    func removeLocalFile() {
        do {
            try FileManager.default.removeItem(at: localFilePath()!)
        } catch let error as NSError {
            logDriveSubdomain(.Model, .Error, "Error deleting file: " + error.localizedDescriptionAndUnderlyingKey)
        }
        YSAppDelegate.appDelegate().filesOnDisk.remove(fileDriveIdentifier)
    }

    var debugDescription: String {
        return "File name: \(fileName) ID: \(fileDriveIdentifier) FolderID: \(folder.folderID) Folder name: \(folder.folderName) IS AUDIO: \(isAudio)\t"
    }

    func fileUrl() -> String {
        return YSDriveFile.fileUrlStatic(fileDriveIdentifier: fileDriveIdentifier)
    }
    
    func localFilePath() -> URL? {
        return YSDriveFile.localFilePathStatic(fileDriveIdentifier: fileDriveIdentifier)
    }

    static func localFilePathStatic(fileDriveIdentifier: String) -> URL? {
        if let url = URL(string: YSDriveFile.fileUrlStatic(fileDriveIdentifier: fileDriveIdentifier)) {
            if url.lastPathComponent.isEmpty {
                return nil
            }
            var fullPath = YSConstants.localFilePathForDownloadingFolder.appendingPathComponent(url.lastPathComponent)
            fullPath.appendPathExtension("mp3")
            return fullPath
        }
        return nil
    }

    static func fileUrlStatic(fileDriveIdentifier: String) -> String {
        return String(format: "%@files/%@?alt=media&key=%@", YSConstants.kDriveAPIEndpoint, fileDriveIdentifier, YSConstants.kDriveAPIKey)
    }
    
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        let fileDictionary = YSNetworkResponseManager.convertToDictionary(from: data)
        return fileDictionary
    }
}

extension YSDriveFile: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: YSDriveFileCodingKeys.self)
        fileDriveIdentifier = try values.decode(String.self, forKey: .fileDriveIdentifier)
        fileName = try values.decode(String.self, forKey: .fileName)
        mimeType = try values.decode(String.self, forKey: .mimeType)
        fileSize = ((try? values.decode(String.self, forKey: .fileSize)) ?? "")
        
        self.playedTime = ""
        self.isPlayed = false
        self.isCurrentlyPlaying = false
        self.isDeletedFromDrive = false
        self.pageToken = ""
    }
}

extension YSDriveFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: YSDriveFileEncodingKeys.self)
        try container.encode(fileDriveIdentifier, forKey: .fileDriveIdentifier)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(folder, forKey: .folder)
        try container.encode(isAudio, forKey: .isAudio)
        try container.encode(isCurrentlyPlaying, forKey: .isCurrentlyPlaying)
        try container.encode(isDeletedFromDrive, forKey: .isDeletedFromDrive)
        try container.encode(isPlayed, forKey: .isPlayed)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(pageToken, forKey: .pageToken)
        try container.encode(playedTime, forKey: .playedTime)
    }
}
