//
//  YSDriveModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDriveModelProtocol {
    var isLoggedIn: Bool {get}

    func getFiles(pageToken: String, nextPageToken: String?, _ completionHandler: @escaping AllFilesCompletionHandler)

    func download(_ fileDriveIdentifier: String)

    func stopDownload(_ fileDriveIdentifier: String)

    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
}
