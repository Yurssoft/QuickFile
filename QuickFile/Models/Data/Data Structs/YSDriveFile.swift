//
//  YSDriveFile.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSDriveFile: YSDriveFileProtocol {
    var name: String //Book 343
    var size: String //108.03 MB (47 audio) or 10:18
    var mimeType: String
    var pageToken: String
    var isAudio: Bool {
        if !mimeType.isEmpty && (mimeType.contains("mp3") || mimeType.contains("audio") || mimeType.contains("mpeg")) {
            return true
        } else {
            return false
        }
    }
    var id: String
    var modifiedTime: String = ""
    var folder: YSFolder = YSFolder()
    var isDeletedFromDrive: Bool = false

    var playedTime: String
    var isPlayed: Bool
    var isCurrentlyPlaying: Bool

    enum YSDriveFileCodingKeys: String, CodingKey {
        case id
        case name
        case size
        case folder
        case isAudio
        case isCurrentlyPlaying
        case isDeletedFromDrive
        case isPlayed
        case mimeType
        case pageToken
        case playedTime
    }
    
    enum YSDriveFileEncodingKeys: String, CodingKey {
        case id
        case name
        case size
        case folder
        case isAudio
        case isCurrentlyPlaying
        case isDeletedFromDrive
        case isPlayed
        case mimeType
        case pageToken
        case playedTime
    }
    
    init(name: String?, size: String?, mimeType: String?, id: String?, folderName: String?, folderID: String?, playedTime: String?, isPlayed: Bool, isCurrentlyPlaying: Bool, isDeletedFromDrive: Bool, pageToken: String?) {
        self.name = name.unwrapped()
        self.size = size.unwrapped()
        self.mimeType = mimeType.unwrapped()
        self.id = id.unwrapped()
        self.folder.folderName = folderName.unwrapped()
        self.folder.folderID = folderID.unwrapped()

        self.playedTime = playedTime.unwrapped()
        self.isPlayed = isPlayed
        self.isCurrentlyPlaying = isCurrentlyPlaying
        self.isDeletedFromDrive = false
        self.pageToken = pageToken.unwrapped()
    }
    
    init(name: String, size: String, mimeType: String, id: String, folderName: String, folderID: String, playedTime: String, isPlayed: Bool, isCurrentlyPlaying: Bool, isDeletedFromDrive: Bool, pageToken: String) {
        self.name = name
        self.size = size
        self.mimeType = mimeType
        self.id = id
        self.folder.folderName = folderName
        self.folder.folderID = folderID
        self.playedTime = playedTime
        self.isPlayed = isPlayed
        self.isCurrentlyPlaying = isCurrentlyPlaying
        self.isDeletedFromDrive = false
        self.pageToken = pageToken
    }

    init() {
        self.name = ""
        self.size = ""
        self.mimeType = ""
        self.id = ""
        self.playedTime = ""
        self.isPlayed = false
        self.isCurrentlyPlaying = false
        self.isDeletedFromDrive = false
        self.pageToken = ""
    }

    func localFileExists() -> Bool {
        return YSDriveFile.localFileExistsStatic(id: id)
    }

    static func localFileExistsStatic(id: String) -> Bool {
        return YSAppDelegate.appDelegate().filesOnDisk.contains(id)
    }

    func removeLocalFile() {
        do {
            try FileManager.default.removeItem(at: localFilePath()!)
        } catch let error as NSError {
            logDriveSubdomain(.Model, .Error, "Error deleting file: " + error.localizedDescriptionAndUnderlyingKey)
        }
        YSAppDelegate.appDelegate().filesOnDisk.remove(id)
    }

    var debugDescription: String {
        return "File name: \(name) ID: \(id) FolderID: \(folder.folderID) Folder name: \(folder.folderName) IS AUDIO: \(isAudio)\t"
    }

    func fileUrl() -> String {
        return YSDriveFile.fileUrlStatic(id: id)
    }
    
    func localFilePath() -> URL? {
        return YSDriveFile.localFilePathStatic(id: id)
    }

    static func localFilePathStatic(id: String) -> URL? {
        if let url = URL(string: YSDriveFile.fileUrlStatic(id: id)) {
            if url.lastPathComponent.isEmpty {
                return nil
            }
            var fullPath = YSConstants.localFilePathForDownloadingFolder.appendingPathComponent(url.lastPathComponent)
            fullPath.appendPathExtension("mp3")
            return fullPath
        }
        return nil
    }

    static func fileUrlStatic(id: String) -> String {
        return String(format: "%@files/%@?alt=media&key=%@", YSConstants.kDriveAPIEndpoint, id, YSConstants.kDriveAPIKey)
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
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        mimeType = try values.decode(String.self, forKey: .mimeType)
        folder = (try? values.decode(YSFolder.self, forKey: .folder)) ?? YSFolder.rootFolder()
        size = (try? values.decode(String.self, forKey: .size)) ?? ""
        playedTime = (try? values.decode(String.self, forKey: .playedTime)) ?? ""
        isPlayed = (try? values.decode(Bool.self, forKey: .isPlayed)) ?? false
        isCurrentlyPlaying = (try? values.decode(Bool.self, forKey: .isCurrentlyPlaying)) ?? false
        isDeletedFromDrive = (try? values.decode(Bool.self, forKey: .isDeletedFromDrive)) ?? false
        pageToken = (try? values.decode(String.self, forKey: .pageToken)) ?? ""
    }
}

extension YSDriveFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: YSDriveFileEncodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
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
