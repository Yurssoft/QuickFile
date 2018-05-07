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

    func getFiles(pageToken: String, nextPageToken: String?, _ completionHandler: @escaping AllFilesCH)

    func download(_ id: String)

    func stopDownload(_ id: String)

    func download(for id: String) -> YSDownloadProtocol?
}
