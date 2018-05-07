//
//  YSDriveModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

class YSDriveModel: YSDriveModelProtocol {
    var isLoggedIn: Bool {
        return YSCredentialManager.isLoggedIn
    }

    private var currentFolder: YSFolder?
    private let taskUIID = UUID().uuidString

    init(folder: YSFolder?) {
        currentFolder = folder
    }

    deinit {
        YSFilesMetadataDownloader.cancelTaskWithIdentifier(taskIdentifier: taskUIID)
    }

    func getFiles(pageToken: String, nextPageToken: String?, _ completionHandler: @escaping AllFilesCH) {
        var url = "\(YSConstants.kDriveAPIEndpoint)files?"
        url.addingPercentEncoding(nextPageToken)
        guard let folder = currentFolder else {
            logDriveSubdomain(.Service, .Error, "No folder")
            return
        }
        url += "corpus=user&orderBy=folder%2Cname&pageSize=\(YSConstants.kPageSize)&q='\(folder.folderID)'+in+parents+and+(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed%3Dfalse&spaces=drive&fields=nextPageToken%2C+files(id%2C+name%2C+size%2C+mimeType)&key=\(YSConstants.kDriveAPIKey)"
        YSFilesMetadataDownloader.downloadFiles(for: url, taskUIID) { files, error in
            if let yserror = error as? YSError {
                if nextPageToken != nil {
                    DispatchQueue.main.async {
                        completionHandler([], yserror, nil)
                    }
                    return
                }
                YSDatabaseManager.offlineFiles(id: folder.folderID, yserror, completionHandler)
                return
            }
            YSDatabaseManager.save(pageToken: pageToken, remoteFiles: files, folder, completionHandler)
        }
    }

    func download(for id: String) -> YSDownloadProtocol? {
        return YSAppDelegate.appDelegate().fileDownloader.download(for: id)
    }

    func download(_ id: String) {
        YSAppDelegate.appDelegate().fileDownloader.download(id: id)
    }

    func stopDownload(_ id: String) {
        YSAppDelegate.appDelegate().fileDownloader.cancelDownloading(id: id)
    }
}
